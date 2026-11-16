import SwiftUI

// MARK: - MetronomeBPMView (View)
// Giant BPM, +/- stepper, slider 30...300.
// Debug: all three call increment / decrement / setBPM. If UI moves but audio does not, ClickPlayer.update is stale.

struct MetronomeBPMView: View {
    let modelView: MetronomeModelView

    var body: some View {
        VStack(spacing: 10) {
            Text(MetronomeCopy.Screen.bpm)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textMuted)

            HStack(spacing: 16) {
                roundIconButton(systemName: "minus") {
                    modelView.decrement()
                }
                Text("\(modelView.bpm)")
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.numeric)
                    .frame(minWidth: 160)
                    .contentTransition(.numericText())
                roundIconButton(systemName: "plus") {
                    modelView.increment()
                }
            }

            Slider(
                value: Binding(
                    get: { Double(modelView.bpm) },
                    set: { modelView.setBPM(Int($0.rounded())) }
                ),
                in: Double(Tempo.minimum)...Double(Tempo.maximum)
            )
            .tint(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
    }

    private func roundIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(AppTheme.accent.opacity(0.7), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}
