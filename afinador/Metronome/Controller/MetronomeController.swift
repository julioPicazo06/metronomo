import SwiftUI

// MARK: - MetronomeController (Controller)
// Injects ClickPlayer + HapticPlayer. Leaving the tab calls disappear() → stop clicks.

struct MetronomeController: View {
    let settings: AppSettingsStore
    var isActive: Bool = true
    @State private var modelView: MetronomeModelView

    init(settings: AppSettingsStore, isActive: Bool = true) {
        self.settings = settings
        self.isActive = isActive
        _modelView = State(
            initialValue: MetronomeModelView(
                player: ClickPlayer(),
                haptics: HapticPlayer(),
                settings: settings
            )
        )
    }

    var body: some View {
        MetronomeView(modelView: modelView)
        .onChange(of: isActive) { _, active in
            if !active {
                modelView.disappear()
            }
        }
    }
}
