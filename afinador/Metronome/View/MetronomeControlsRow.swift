import SwiftUI

// MARK: - MetronomeControlsRow (View)
// Tap tempo (2+ hits within 2s) + Play/Stop.
// Debug: Play → ClickPlayer.start. Stop → ClickPlayer.stop.

struct MetronomeControlsRow: View {
    let modelView: MetronomeModelView

    var body: some View {
        HStack(spacing: 28) {
            VStack(spacing: 8) {
                Button {
                    modelView.tap()
                } label: {
                    Text(MetronomeCopy.Controls.tap)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(modelView.isTapping ? AppTheme.canvas : AppTheme.textPrimary)
                        .frame(width: 120, height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(modelView.isTapping ? AppTheme.info : AppTheme.surface)
                        )
                }
                .buttonStyle(.plain)
                Text(modelView.isTapping ? MetronomeCopy.Controls.tapping : MetronomeCopy.Controls.tapTempo)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)
            }

            VStack(spacing: 8) {
                Button {
                    modelView.togglePlay()
                } label: {
                    Image(systemName: modelView.isPlaying ? "stop.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 84, height: 84)
                        .background(Circle().fill(AppTheme.accent))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(modelView.isPlaying ? MetronomeCopy.Controls.stop : MetronomeCopy.Controls.play)
                Text(modelView.isPlaying ? MetronomeCopy.Controls.stop : MetronomeCopy.Controls.play)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}
