import SwiftUI

// MARK: - App entry
// @main scene. RootController owns the TabView and the shared AppSettingsStore.
// Debug: if you still see Hello World, this file is not the run target.

@main
struct afinadorApp: App {
    var body: some Scene {
        WindowGroup {
            RootController()
        }
    }
}
