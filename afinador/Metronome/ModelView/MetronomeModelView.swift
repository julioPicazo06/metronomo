import Foundation
import Observation

// MARK: - MetronomeModelView (ModelView)
// Brain of the Metronome screen. Tempo / signature / subdivision / play.
// Audio is ClickPlaying (injected). Debug: togglePlay() → start/stop; tap() needs 2+ hits.

@Observable
final class MetronomeModelView {
    private let player: ClickPlaying
    private let haptics: HapticPlaying
    private let settings: AppSettingsStore

    var tempo: Tempo
    var timeSignature: TimeSignature = .fourFour
    var subdivision: Subdivision = .quarter
    var isPlaying = false
    var isTapping = false
    var currentBeat = 1
    var showsSoundSheet = false

    private var tapDates: [Date] = []

    var bpm: Int { tempo.bpm }
    var sound: ClickSound { settings.metronomeSound }

    init(player: ClickPlaying, haptics: HapticPlaying, settings: AppSettingsStore) {
        self.player = player
        self.haptics = haptics
        self.settings = settings
        self.tempo = Tempo(bpm: settings.lastBPM)
    }

    func disappear() {
        stop()
    }

    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }

    func increment() {
        tempo.increment()
        persistAndRefresh()
    }

    func decrement() {
        tempo.decrement()
        persistAndRefresh()
    }

    func setBPM(_ value: Int) {
        tempo.set(value)
        persistAndRefresh()
    }

    func selectSignature(_ signature: TimeSignature) {
        timeSignature = signature
        currentBeat = 1
        persistAndRefresh()
    }

    func selectSubdivision(_ subdivision: Subdivision) {
        self.subdivision = subdivision
        persistAndRefresh()
    }

    func selectSound(_ sound: ClickSound) {
        settings.metronomeSound = sound
        showsSoundSheet = false
        persistAndRefresh()
    }

    func tap() {
        let now = Date()
        if let last = tapDates.last, now.timeIntervalSince(last) > 2 {
            tapDates.removeAll()
        }
        tapDates.append(now)
        isTapping = true
        if tapDates.count >= 2 {
            let intervals = zip(tapDates.dropFirst(), tapDates).map { $0.timeIntervalSince($1) }
            if let next = Tempo.fromTapIntervals(intervals) {
                tempo = next
                persistAndRefresh()
            }
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if let last = tapDates.last, Date().timeIntervalSince(last) >= 1.1 {
                isTapping = false
            }
        }
    }

    private func start() {
        isPlaying = true
        currentBeat = 1
        player.start(
            bpm: tempo.bpm,
            beatsPerMeasure: timeSignature.beats,
            clicksPerBeat: subdivision.clicksPerBeat,
            sound: settings.metronomeSound
        ) { [weak self] beat, isAccent in
            self?.currentBeat = beat
            if self?.settings.hapticsEnabled == true {
                self?.haptics.playClick(isAccent: isAccent)
            }
        }
    }

    private func stop() {
        isPlaying = false
        player.stop()
        currentBeat = 1
        isTapping = false
    }

    private func persistAndRefresh() {
        settings.lastBPM = tempo.bpm
        guard isPlaying else { return }
        player.update(
            bpm: tempo.bpm,
            beatsPerMeasure: timeSignature.beats,
            clicksPerBeat: subdivision.clicksPerBeat,
            sound: settings.metronomeSound
        )
    }
}
