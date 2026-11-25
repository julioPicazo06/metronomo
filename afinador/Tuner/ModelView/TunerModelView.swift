import Foundation
import Observation

// MARK: - TunerModelView (ModelView)
// Brain of the Tuner screen. Translates Hz → displayedNote / cents / status.
// Does not own AVAudioEngine — PitchDetecting is injected (real or FakePitchDetector).
// Debug breakpoints: ingest(_:), scheduleIdleReset(), apply(permission:).

@Observable
final class TunerModelView {
    /// Silence window before returning to idle. Sleep and eligibility check share this value.
    static let idleResetInterval: TimeInterval = 0.85
    static var idleResetNanoseconds: UInt64 { UInt64(idleResetInterval * 1_000_000_000) }

    private let detector: PitchDetecting
    private let permission: MicrophonePermitting
    private let opener: SystemOpening
    private let haptics: HapticPlaying
    private let settings: AppSettingsStore

    var instrument: InstrumentKind
    var preset: TuningPreset
    var mode: TunerMode = .strings
    var lockedStringIndex: Int?
    var status: TunerStatus = .idle
    var reading: TuningReading?
    var sheets = Sheets()

    struct Sheets {
        var tuning = false
        var instrument = false
    }

    private var lastSignalDate: Date?
    private var lastInTune = false
    private var idleTask: Task<Void, Never>?

    var strings: [Note] { preset.strings }
    var a4: Double { settings.a4Frequency }
    var threshold: Double { settings.inTuneThreshold }
    var hasSignal: Bool { reading != nil && status != .idle }

    // MARK: Displayed values
    // Idle keeps a rest note on screen (selected / first string, or A4 in chromatic).

    var restNote: Note {
        if mode == .strings {
            let index = lockedStringIndex ?? 0
            if strings.indices.contains(index) {
                return strings[index]
            }
        }
        return Note(pitchClass: .a, octave: 4)
    }

    var displayedNote: Note { hasSignal ? (reading?.note ?? restNote) : restNote }
    var displayedFrequency: Double {
        hasSignal ? (reading?.frequency ?? restNote.frequency(a4: a4)) : restNote.frequency(a4: a4)
    }
    var displayedCents: Double { hasSignal ? (reading?.cents ?? 0) : 0 }
    var highlightedStringIndex: Int? {
        if mode != .strings { return nil }
        if hasSignal { return reading?.stringIndex ?? lockedStringIndex ?? 0 }
        return lockedStringIndex ?? 0
    }

    var centsForNeedle: Double {
        min(50, max(-50, displayedCents))
    }

    init(
        detector: PitchDetecting,
        permission: MicrophonePermitting,
        opener: SystemOpening,
        haptics: HapticPlaying,
        settings: AppSettingsStore
    ) {
        self.detector = detector
        self.permission = permission
        self.opener = opener
        self.haptics = haptics
        self.settings = settings
        self.instrument = settings.defaultInstrument
        self.preset = settings.defaultInstrument.defaultPreset
        self.detector.onFrequency = { [weak self] frequency in
            self?.ingest(frequency)
        }
    }

    func appear() {
        instrument = settings.defaultInstrument
        if preset.id.hasPrefix(instrument.rawValue) == false {
            preset = instrument.defaultPreset
        }
        Task {
            await prepareMicrophone()
        }
    }

    func disappear() {
        detector.stop()
        idleTask?.cancel()
    }

    func selectInstrument(_ kind: InstrumentKind) {
        sheets.instrument = false
        if instrument == kind { return }
        instrument = kind
        preset = kind.defaultPreset
        lockedStringIndex = nil
        settings.defaultInstrument = kind
        reading = nil
        if status != .noMicrophone && status != .unavailable {
            status = .idle
        }
    }

    func selectPreset(_ preset: TuningPreset) {
        self.preset = preset
        lockedStringIndex = nil
        sheets.tuning = false
    }

    func selectMode(_ mode: TunerMode) {
        self.mode = mode
        lockedStringIndex = nil
        if mode == .chromatic {
            reading = reading.map {
                TuningAnalyzer.reading(
                    frequency: $0.frequency,
                    mode: .chromatic,
                    strings: strings,
                    lockedStringIndex: nil,
                    a4: a4
                )
            }
        }
    }

    func selectString(at index: Int) {
        lockedStringIndex = lockedStringIndex == index ? nil : index
        if let frequency = reading?.frequency {
            ingest(frequency)
        }
    }

    func openSystemSettings() {
        opener.openAppSettings()
    }

    // MARK: Pitch ingest
    // Called from PitchDetector.onFrequency (main actor). After idleResetInterval of silence,
    // status returns to idle but the rest note stays visible.

    func ingest(_ frequency: Double) {
        guard status != .noMicrophone, status != .unavailable else { return }
        lastSignalDate = Date()
        let next = TuningAnalyzer.reading(
            frequency: frequency,
            mode: mode,
            strings: strings,
            lockedStringIndex: lockedStringIndex,
            a4: a4
        )
        reading = next
        let nextStatus = next.status(threshold: threshold)
        status = nextStatus

        if nextStatus == .inTune, lastInTune == false, settings.hapticsEnabled {
            haptics.playInTune()
        }
        lastInTune = nextStatus == .inTune
        scheduleIdleReset()
    }

    private func scheduleIdleReset() {
        idleTask?.cancel()
        idleTask = Task {
            try? await Task.sleep(nanoseconds: Self.idleResetNanoseconds)
            guard !Task.isCancelled else { return }
            if let lastSignalDate, Date().timeIntervalSince(lastSignalDate) >= Self.idleResetInterval {
                reading = nil
                lastInTune = false
                if status != .noMicrophone && status != .unavailable {
                    status = .idle
                }
            }
        }
    }

    private func prepareMicrophone() async {
        var current = permission.currentStatus()
        if current == .undetermined {
            current = await permission.requestAccess()
        }
        apply(permission: current)
    }

    private func apply(permission current: MicrophoneStatus) {
        switch current {
        case .granted:
            if status == .noMicrophone || status == .unavailable {
                status = .idle
            }
            do {
                try detector.start()
            } catch {
                status = .unavailable
            }
        case .denied:
            detector.stop()
            status = .noMicrophone
            reading = nil
        case .undetermined:
            status = .idle
        case .unavailable:
            detector.stop()
            status = .unavailable
            reading = nil
        }
    }
}
