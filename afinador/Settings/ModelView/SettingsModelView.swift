import Foundation
import Observation

// MARK: - SettingsModelView (ModelView)
// Sheet flags grouped in `sheets`; writes go into AppSettingsStore.

@Observable
final class SettingsModelView {
    let store: AppSettingsStore
    var sheets = Sheets()

    struct Sheets {
        var a4 = false
        var threshold = false
        var instrument = false
        var sound = false
    }

    var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? SettingsCopy.Version.fallback
        return SettingsCopy.Version.label(version: version)
    }

    init(store: AppSettingsStore) {
        self.store = store
    }

    func selectA4(_ value: Double) {
        store.a4Frequency = value
        sheets.a4 = false
    }

    func selectThreshold(_ value: Double) {
        store.inTuneThreshold = value
        sheets.threshold = false
    }

    func selectInstrument(_ kind: InstrumentKind) {
        store.defaultInstrument = kind
        sheets.instrument = false
    }

    func selectSound(_ sound: ClickSound) {
        store.metronomeSound = sound
        sheets.sound = false
    }
}
