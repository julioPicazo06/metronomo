import SwiftUI

// MARK: - ChipButton (Shared UI)
// Toggle used for tuner mode (segment) and time signatures (capsule).
// Debug: isSelected only changes visuals — the action must update ModelView state.

enum ChipButtonLayout {
    case capsule
    /// Equal-width segment inside a segmented control row.
    case segment
}

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    var layout: ChipButtonLayout = .capsule
    var selectedFill: Color = AppTheme.success.opacity(0.18)
    var selectedStroke: Color = AppTheme.success
    var selectedText: Color = AppTheme.successAlt
    var unselectedFill: Color = AppTheme.surface
    var unselectedStroke: Color = AppTheme.border.opacity(0.35)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            switch layout {
            case .capsule:
                label
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(fillColor))
                    .overlay(Capsule().stroke(strokeColor, lineWidth: 1))
            case .segment:
                label
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(fillColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(strokeColor, lineWidth: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var label: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? selectedText : AppTheme.textMuted)
    }

    private var fillColor: Color {
        isSelected ? selectedFill : unselectedFill
    }

    private var strokeColor: Color {
        isSelected ? selectedStroke : unselectedStroke
    }
}
