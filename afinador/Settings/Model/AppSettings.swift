import Foundation

// MARK: - AppSettings (Model)
// Snapshot of user prefs. Persistence is AppSettingsStore (UserDefaults, prefix afinador.settings.).

struct AppSettings: Equatable, Sendable {
    var a4Frequency: Double
    var inTuneThreshold: Double
    /// Single instrument preference (Settings + Tuner).
    var defaultInstrument: InstrumentKind
    var keepScreenAwake: Bool
    var hapticsEnabled: Bool
    var metronomeSound: ClickSound
    var lastTabIndex: Int
    var lastBPM: Int

    static let `default` = AppSettings(
        a4Frequency: 440,
        inTuneThreshold: 5,
        defaultInstrument: .guitar,
        keepScreenAwake: true,
        hapticsEnabled: true,
        metronomeSound: .click,
        lastTabIndex: 0,
        lastBPM: Tempo.default
    )

    static let a4Options: [Double] = [432, 440, 442]
    static let thresholdOptions: [Double] = [3, 5, 10]

    /// Boundary parse: unknown UserDefaults values fall back to defaults.
    static func sanitizedA4(_ value: Double) -> Double {
        a4Options.contains(value) ? value : `default`.a4Frequency
    }

    static func sanitizedThreshold(_ value: Double) -> Double {
        thresholdOptions.contains(value) ? value : `default`.inTuneThreshold
    }
}
