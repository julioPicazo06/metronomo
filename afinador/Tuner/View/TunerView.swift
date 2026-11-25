import SwiftUI

// MARK: - TunerView (View canvas)
// Composes selectors + named children. No AVAudioEngine — TunerModelView owns state.
// Debug: needle stuck → ingest() in TunerModelView. Note gone → hasSignal / idle reset.

struct TunerView: View {
    let modelView: TunerModelView

    var body: some View {
        VStack(spacing: 16) {
            header
            instrumentButton
            presetButton
            modeRow
            TunerGaugeView(
                cents: modelView.centsForNeedle,
                isInTune: modelView.status == .inTune,
                isActive: modelView.hasSignal
            )
            .frame(height: 188)
            .animation(.easeOut(duration: 0.18), value: modelView.centsForNeedle)
            TunerReadoutView(modelView: modelView)

            if modelView.status == .noMicrophone || modelView.status == .unavailable {
                TunerMicPermissionView(modelView: modelView)
            } else if modelView.mode == .strings {
                TunerStringsRow(modelView: modelView)
            } else {
                Text(TunerCopy.Screen.chromaticHint)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textMuted)
                    .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(AppTheme.canvas.ignoresSafeArea())
        .sheet(isPresented: Binding(
            get: { modelView.sheets.instrument },
            set: { modelView.sheets.instrument = $0 }
        )) {
            OptionPickerSheet(
                title: TunerCopy.Instrument.sheetTitle,
                options: InstrumentKind.allCases.map { ($0.title, $0) },
                selected: modelView.instrument,
                onSelect: modelView.selectInstrument
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: Binding(
            get: { modelView.sheets.tuning },
            set: { modelView.sheets.tuning = $0 }
        )) {
            TuningPresetSheet(modelView: modelView)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Header + selectors
    // Instrument / preset open sheets; mode is a full-width tab so chips don't clutter the top.

    private var header: some View {
        HStack {
            Text(TunerCopy.Screen.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var instrumentButton: some View {
        HStack {
            Button {
                modelView.sheets.instrument = true
            } label: {
                HStack(spacing: 8) {
                    Text(modelView.instrument.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.successAlt)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.success)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppTheme.success.opacity(0.18))
                )
                .overlay(
                    Capsule()
                        .stroke(AppTheme.success, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
    }

    private var presetButton: some View {
        Button {
            modelView.sheets.tuning = true
        } label: {
            HStack(spacing: 4) {
                Text(modelView.preset.name)
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(AppTheme.textMuted)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var modeRow: some View {
        HStack(spacing: 0) {
            ForEach(TunerMode.allCases, id: \.self) { mode in
                ChipButton(
                    title: mode.title,
                    isSelected: modelView.mode == mode,
                    layout: .segment,
                    unselectedFill: .clear,
                    unselectedStroke: .clear
                ) {
                    modelView.selectMode(mode)
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border.opacity(0.35), lineWidth: 1)
        )
    }
}
