import SwiftUI

// MARK: - MetronomeSignatureRow (View)
// Time signature chips 2/4 3/4 4/4 6/8. Changing this resets currentBeat to 1.

struct MetronomeSignatureRow: View {
    let modelView: MetronomeModelView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(MetronomeCopy.Screen.signature)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            HStack(spacing: 10) {
                ForEach(TimeSignature.allCases, id: \.self) { signature in
                    ChipButton(
                        title: signature.label,
                        isSelected: modelView.timeSignature == signature,
                        selectedFill: AppTheme.success.opacity(0.12),
                        selectedStroke: AppTheme.success,
                        selectedText: AppTheme.emphasis
                    ) {
                        modelView.selectSignature(signature)
                    }
                }
            }
        }
    }
}
