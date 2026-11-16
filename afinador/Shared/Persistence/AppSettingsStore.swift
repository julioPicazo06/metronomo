import Foundation
import Observation

// MARK: - AppSettingsStore
// Observable wrapper around UserDefaults. Inject a suiteName store in tests.
// Keys: afinador.settings.{a4,threshold,sound,bpm,tab,...}. didSet on `settings` persists.

@Observable
final class AppSettingsStore {
    private let defaults: UserDefaults
    private let prefix = "afinador.settings."

    var settings: AppSettings {
        didSet { persist() }
    }

    var a4Frequency: Double {
        get { settings.a4Frequency }
        set { settings.a4Frequency = newValue }
    }

    var inTuneThreshold: Double {
        get { settings.inTuneThreshold }
        set { settings.inTuneThreshold = newValue }
    }

    var defaultInstrument: InstrumentKind {
        get { settings.defaultInstrument }
        set { settings.defaultInstrument = newValue }
    }

    var keepScreenAwake: Bool {
        get { settings.keepScreenAwake }
        set { settings.keepScreenAwake = newValue }
    }

    var hapticsEnabled: Bool {
        get { settings.hapticsEnabled }
        set { settings.hapticsEnabled = newValue }
    }

    var metronomeSound: ClickSound {
        get { settings.metronomeSound }
        set { settings.metronomeSound = newValue }
    }

    var lastTabIndex: Int {
        get { settings.lastTabIndex }
        set { settings.lastTabIndex = newValue }
    }

    var lastBPM: Int {
        get { settings.lastBPM }
        set { settings.lastBPM = Tempo.clamped(newValue) }
    }

    var lastInstrument: InstrumentKind {
        get { settings.lastInstrument }
        set { settings.lastInstrument = newValue }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.settings = AppSettingsStore.load(from: defaults, prefix: "afinador.settings.")
    }

    private func persist() {
        defaults.set(settings.a4Frequency, forKey: prefix + "a4")
        defaults.set(settings.inTuneThreshold, forKey: prefix + "threshold")
        defaults.set(settings.defaultInstrument.rawValue, forKey: prefix + "defaultInstrument")
        defaults.set(settings.keepScreenAwake, forKey: prefix + "keepAwake")
        defaults.set(settings.hapticsEnabled, forKey: prefix + "haptics")
        defaults.set(settings.metronomeSound.rawValue, forKey: prefix + "sound")
        defaults.set(settings.lastTabIndex, forKey: prefix + "tab")
        defaults.set(settings.lastBPM, forKey: prefix + "bpm")
        defaults.set(settings.lastInstrument.rawValue, forKey: prefix + "instrument")
    }

    private static func load(from defaults: UserDefaults, prefix: String) -> AppSettings {
        var loaded = AppSettings.default
        if defaults.object(forKey: prefix + "a4") != nil {
            loaded.a4Frequency = defaults.double(forKey: prefix + "a4")
        }
        if defaults.object(forKey: prefix + "threshold") != nil {
            loaded.inTuneThreshold = defaults.double(forKey: prefix + "threshold")
        }
        if let raw = defaults.string(forKey: prefix + "defaultInstrument"),
           let kind = InstrumentKind(rawValue: raw) {
            loaded.defaultInstrument = kind
        }
        if defaults.object(forKey: prefix + "keepAwake") != nil {
            loaded.keepScreenAwake = defaults.bool(forKey: prefix + "keepAwake")
        }
        if defaults.object(forKey: prefix + "haptics") != nil {
            loaded.hapticsEnabled = defaults.bool(forKey: prefix + "haptics")
        }
        if let raw = defaults.string(forKey: prefix + "sound"),
           let sound = ClickSound(rawValue: raw) {
            loaded.metronomeSound = sound
        }
        if defaults.object(forKey: prefix + "tab") != nil {
            loaded.lastTabIndex = defaults.integer(forKey: prefix + "tab")
        }
        if defaults.object(forKey: prefix + "bpm") != nil {
            loaded.lastBPM = Tempo.clamped(defaults.integer(forKey: prefix + "bpm"))
        }
        if let raw = defaults.string(forKey: prefix + "instrument"),
           let kind = InstrumentKind(rawValue: raw) {
            loaded.lastInstrument = kind
        }
        return loaded
    }
}
