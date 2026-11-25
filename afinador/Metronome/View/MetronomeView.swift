import SwiftUI

// MARK: - MetronomeView (View canvas)
// Composes named children. Does not own ClickPlayer — MetronomeModelView + Controller do.
// Debug: speaker → OptionPickerSheet. Play lives in MetronomeControlsRow.

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
            get: { modelView.sheets.sound },
            set: { modelView.sheets.sound = $0 }
        )) {
            OptionPickerSheet(
                title: MetronomeCopy.Screen.soundSheetTitle,
                options: ClickSound.allCases.map { ($0.title, $0) },
                selected: modelView.sound,
                onSelect: modelView.selectSound
            )
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Header
    // Title + speaker (opens shared OptionPickerSheet).

    private var header: some View {
        HStack {
            Text(MetronomeCopy.Screen.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Spacer()
            Button {
                modelView.sheets.sound = true
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
