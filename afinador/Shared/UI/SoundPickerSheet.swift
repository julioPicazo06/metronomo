import SwiftUI

// MARK: - SoundPickerSheet (Shared UI)
// Click / wood / beep / mute. Used by MetronomeView (speaker) and SettingsView.
// Debug: onSelect must write AppSettingsStore.metronomeSound or clicks will not change.

struct SoundPickerSheet: View {
    let selected: ClickSound
    let onSelect: (ClickSound) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(MetronomeCopy.Screen.soundSheetTitle)
                .font(.title3.bold())
                .foregroundStyle(.white)

            ForEach(ClickSound.allCases, id: \.self) { sound in
                Button {
                    onSelect(sound)
                } label: {
                    HStack {
                        Text(sound.title)
                            .foregroundStyle(.white)
                        Spacer()
                        if selected == sound {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.success)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(selected == sound ? AppTheme.success : AppTheme.border.opacity(0.4), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppTheme.surface)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.chrome.ignoresSafeArea())
    }
}
