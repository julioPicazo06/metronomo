import Foundation
import Observation

// MARK: - SettingsModelView (ModelView)
// Sheet flags + writes into AppSettingsStore. No local copy of settings.

@Observable
final class SettingsModelView {
    let store: AppSettingsStore
    var showsA4Sheet = false
    var showsThresholdSheet = false
    var showsInstrumentSheet = false
    var showsSoundSheet = false

    var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? SettingsCopy.Version.fallback
        return SettingsCopy.Version.label(version: version)
    }

    init(store: AppSettingsStore) {
        self.store = store
    }

    func selectA4(_ value: Double) {
        store.a4Frequency = value
        showsA4Sheet = false
    }

    func selectThreshold(_ value: Double) {
        store.inTuneThreshold = value
        showsThresholdSheet = false
    }

    func selectInstrument(_ kind: InstrumentKind) {
        store.defaultInstrument = kind
        store.lastInstrument = kind
        showsInstrumentSheet = false
    }

    func selectSound(_ sound: ClickSound) {
        store.metronomeSound = sound
        showsSoundSheet = false
    }
}
