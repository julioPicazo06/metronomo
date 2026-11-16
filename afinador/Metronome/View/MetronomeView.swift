import SwiftUI

// MARK: - MetronomeView (View canvas)
// Composes named children. Does not own ClickPlayer — MetronomeModelView + Controller do.
// Debug: speaker → SoundPickerSheet. Play lives in MetronomeControlsRow.

struct MetronomeView: View {
    let modelView: MetronomeModelView

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            MetronomePulsesRow(modelView: modelView, sizeStep: 40)
            MetronomeBPMView(modelView: modelView)
            MetronomeSignatureRow(modelView: modelView)
            MetronomeSubdivisionRow(modelView: modelView)
            MetronomeControlsRow(modelView: modelView)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(AppTheme.canvas.ignoresSafeArea())
        .sheet(isPresented: Binding(
            get: { modelView.showsSoundSheet },
            set: { modelView.showsSoundSheet = $0 }
        )) {
            SoundPickerSheet(selected: modelView.sound) { sound in
                modelView.selectSound(sound)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Header
    // Title + speaker (opens shared SoundPickerSheet).

    private var header: some View {
        HStack {
            Text(MetronomeCopy.Screen.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Spacer()
            Button {
                modelView.showsSoundSheet = true
            } label: {
                Image(systemName: "speaker.wave.2")
                    .font(.title3)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(8)
            }
            .accessibilityLabel(MetronomeCopy.Screen.soundAccessibility)
        }
    }
}
