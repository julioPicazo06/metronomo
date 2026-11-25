import SwiftUI

// MARK: - OptionPickerSheet (Shared UI)
// Generic single-select sheet for A4, cents threshold, instrument, metronome sound.
// Debug: Value: Equatable so the checkmark matches the current store value.

struct OptionPickerSheet<Value: Equatable>: View {
    let title: String
    let options: [(String, Value)]
    let selected: Value
    let onSelect: (Value) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.bottom, 8)
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                Button {
                    onSelect(option.1)
                } label: {
                    HStack {
                        Text(option.0)
                            .foregroundStyle(.white)
                        Spacer()
                        if option.1 == selected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.success)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.surface)
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.chrome.ignoresSafeArea())
        .presentationDetents([.medium])
    }
}
