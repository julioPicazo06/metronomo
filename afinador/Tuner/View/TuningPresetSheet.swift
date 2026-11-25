import SwiftUI

// MARK: - TuningPresetSheet (View)
// Guitar / bass / violin / ukulele presets for the current instrument.
// Debug: selectPreset replaces preset.strings — chips and restNote update at once.

struct TuningPresetSheet: View {
    let modelView: TunerModelView

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(TunerCopy.Preset.sheetTitle(instrument: modelView.instrument.title))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    modelView.sheets.tuning = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(AppTheme.textMuted)
                }
            }

            ForEach(modelView.instrument.presets) { preset in
                Button {
                    modelView.selectPreset(preset)
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(modelView.preset.id == preset.id ? AppTheme.success : .clear)
                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                            .frame(width: 14, height: 14)
                        Text(TunerCopy.Preset.row(name: preset.name, summary: preset.summary))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(modelView.preset.id == preset.id ? AppTheme.success : AppTheme.border.opacity(0.4), lineWidth: 1)
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
