import SwiftUI

// MARK: - SettingsController (Controller)
// Same AppSettingsStore instance as Tuner/Metronome (created in RootController).

struct SettingsController: View {
    let settings: AppSettingsStore
    @State private var modelView: SettingsModelView

    init(settings: AppSettingsStore) {
        self.settings = settings
        _modelView = State(initialValue: SettingsModelView(store: settings))
    }

    var body: some View {
        SettingsView(modelView: modelView)
    }
}
