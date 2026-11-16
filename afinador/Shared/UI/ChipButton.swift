import SwiftUI

// MARK: - ChipButton (Shared UI)
// Capsule toggle used for instruments, tuner mode, and time signatures.
// Debug: isSelected only changes visuals — the action must update ModelView state.

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    var selectedFill: Color = AppTheme.success.opacity(0.18)
    var selectedStroke: Color = AppTheme.success
    var selectedText: Color = AppTheme.successAlt
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? selectedText : AppTheme.textMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? selectedFill : AppTheme.surface)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? selectedStroke : AppTheme.border.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
