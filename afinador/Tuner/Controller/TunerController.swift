import SwiftUI

// MARK: - TunerController (Controller)
// Wires real audio: PitchDetector + MicrophonePermission + HapticPlayer + AppSettingsStore.
// Tests inject fakes into TunerModelView directly — they never instantiate this type.
// Debug: appear() requests mic and starts the engine; disappear() stops the tap.

struct TunerController: View {
    let settings: AppSettingsStore
    var isActive: Bool = true
    @State private var modelView: TunerModelView

    init(settings: AppSettingsStore, isActive: Bool = true) {
        self.settings = settings
        self.isActive = isActive
        _modelView = State(
            initialValue: TunerModelView(
                detector: PitchDetector(),
                permission: MicrophonePermission(),
                opener: SystemOpener(),
                haptics: HapticPlayer(),
                settings: settings
            )
        )
    }

    var body: some View {
        TunerView(modelView: modelView)
            .onAppear { if isActive { modelView.appear() } }
            .onChange(of: isActive) { _, active in
                if active {
                    modelView.appear()
                } else {
                    modelView.disappear()
                }
            }
    }
}
