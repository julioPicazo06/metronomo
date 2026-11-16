import SwiftUI

// MARK: - TunerReadoutView (View)
// Note / Hz / cents / status. Idle still shows rest string (E2 on guitar); needle at 0.
// Debug: displayedNote is never empty. hasSignal=false → rest values, not a hidden readout.

struct TunerReadoutView: View {
    let modelView: TunerModelView

    var body: some View {
        let note = modelView.displayedNote
        return VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(note.displayName)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("\(note.octave)")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .baselineOffset(18)
            }
            .foregroundStyle(AppTheme.emphasis)
            .opacity(modelView.hasSignal ? 1 : 0.85)

            if modelView.status != .noMicrophone && modelView.status != .unavailable {
                Text(AppCopy.Format.hz(modelView.displayedFrequency))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(AppTheme.numeric)

                Text(AppCopy.Format.cents(modelView.displayedCents))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(AppTheme.numeric.opacity(0.9))

                statusLine
            }
        }
    }

    // MARK: Status line
    // idle muted, listening magenta, inTune lime, sharp/flat orange.

    private var statusLine: some View {
        HStack(spacing: 8) {
            switch modelView.status {
            case .idle:
                Text(TunerCopy.Status.idle)
                    .foregroundStyle(AppTheme.textMuted)
            case .listening:
                Circle().fill(AppTheme.accent).frame(width: 8, height: 8)
                Text(TunerCopy.Status.listening)
                    .foregroundStyle(AppTheme.accent)
            case .inTune:
                Image(systemName: "checkmark")
                Text(TunerCopy.Status.inTune)
                    .foregroundStyle(AppTheme.success)
            case .sharp:
                Image(systemName: "arrow.up")
                Text(TunerCopy.Status.sharp)
                    .foregroundStyle(AppTheme.warning)
            case .flat:
                Image(systemName: "arrow.down")
                Text(TunerCopy.Status.flat)
                    .foregroundStyle(AppTheme.warning)
            case .noMicrophone, .unavailable:
                EmptyView()
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(statusColor)
        .padding(.top, 2)
    }

    private var statusColor: Color {
        switch modelView.status {
        case .inTune: AppTheme.success
        case .sharp, .flat: AppTheme.warning
        case .listening: AppTheme.accent
        default: AppTheme.textMuted
        }
    }
}
