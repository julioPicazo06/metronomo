import SwiftUI

// MARK: - TunerMicPermissionView (View)
// Shown when mic is denied or held by another app. PitchDetector is stopped.
// Debug: CTA → SystemOpener → UIApplication.openSettingsURLString.

struct TunerMicPermissionView: View {
    let modelView: TunerModelView

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.accent)
                .padding(18)
                .overlay(
                    Circle().stroke(AppTheme.accent.opacity(0.8), lineWidth: 3)
                )

            Text(modelView.status == .unavailable ? TunerCopy.Mic.inUse : TunerCopy.Mic.disabled)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(TunerCopy.Mic.hint)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textMuted)

            Button(TunerCopy.Mic.openSettings) {
                modelView.openSystemSettings()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Capsule().fill(AppTheme.accent))
            .padding(.top, 8)
        }
        .padding(.top, 12)
    }
}
