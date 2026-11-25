import SwiftUI
import UIKit

// MARK: - RootController (Controller)
// App shell: TabView + shared AppSettingsStore.
// Tabs: 0 Tuner, 1 Metronome, 2 Settings. Last tab is persisted.
// Debug: isActive stops PitchDetector / ClickPlayer when leaving a tab (TabView keeps children alive).
// Keep-awake → UIApplication.isIdleTimerDisabled.

struct RootController: View {
    @State private var settings = AppSettingsStore()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TunerController(settings: settings, isActive: selectedTab == 0)
                .tabItem {
                    Label(AppCopy.Tab.tuner, systemImage: "tuningfork")
                }
                .tag(0)

            MetronomeController(settings: settings, isActive: selectedTab == 1)
                .tabItem {
                    Label(AppCopy.Tab.metronome, systemImage: "metronome")
                }
                .tag(1)

            SettingsController(settings: settings)
                .tabItem {
                    Label(AppCopy.Tab.settings, systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(AppTheme.success)
        .preferredColorScheme(.dark)
        .onAppear {
            configureTabBar()
            selectedTab = settings.lastTabIndex
            applyIdleTimer()
        }
        .onChange(of: selectedTab) { _, newValue in
            settings.lastTabIndex = newValue
        }
        .onChange(of: settings.keepScreenAwake) { _, _ in
            applyIdleTimer()
        }
    }

    private func applyIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = settings.keepScreenAwake
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 16 / 255, green: 23 / 255, blue: 27 / 255, alpha: 1)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    RootController()
}
