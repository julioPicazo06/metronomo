import SwiftUI

// MARK: - MetronomePulsesRow (View)
// One dot per beat. Beat 1 is lime (downbeat). currentBeat comes from ClickPlayer.onBeat.

struct MetronomePulsesRow: View {
    let modelView: MetronomeModelView
    let sizeStep: CGFloat
    

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(MetronomeCopy.Screen.pulses)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            HStack(spacing: 16) {
                ForEach(1...modelView.timeSignature.beats, id: \.self) { beat in
                    Circle()
                        .fill(dotColor(for: beat))
                        .frame(width: sizeStep, height: sizeStep)
                }
                .frame(maxWidth: .infinity)
            }
            
        }
    }

    private func dotColor(for beat: Int) -> Color {
        if beat == 1 {
            return AppTheme.success
        }
        if modelView.isPlaying {
            return beat == modelView.currentBeat ? AppTheme.info : AppTheme.info.opacity(0.55)
        }
        return AppTheme.border.opacity(0.55)
    }
}
