import SwiftUI

// MARK: - TunerStringsRow (View)
// One chip per open string. Magenta = highlighted / locked. Idle defaults to index 0.

struct TunerStringsRow: View {
    let modelView: TunerModelView

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(modelView.strings.enumerated()), id: \.offset) { index, note in
                let selected = modelView.highlightedStringIndex == index
                Button {
                    modelView.selectString(at: index)
                } label: {
                    Text(note.chipLabel)
                        .font(.subheadline.monospaced().weight(.semibold))
                        .foregroundStyle(selected ? AppTheme.accent : AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(selected ? AppTheme.accent : AppTheme.border.opacity(0.45), lineWidth: selected ? 2 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}
