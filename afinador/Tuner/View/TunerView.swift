import SwiftUI

// MARK: - TunerView (View canvas)
// Composes chips + named children. No AVAudioEngine — TunerModelView owns state.
// Debug: needle stuck → ingest() in TunerModelView. Note gone → hasSignal / idle reset.

struct TunerView: View {
    let modelView: TunerModelView

    var body: some View {
        VStack(spacing: 16) {
            header
            instrumentRow
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
            get: { modelView.showsTuningSheet },
            set: { modelView.showsTuningSheet = $0 }
        )) {
            TuningPresetSheet(modelView: modelView)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Header + chips
    // Instrument / preset / mode stay here: small composition, not their own product names.

    private var header: some View {
        HStack {
            Text(TunerCopy.Screen.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var instrumentRow: some View {
        HStack(spacing: 10) {
            ForEach(InstrumentKind.allCases, id: \.self) { kind in
                ChipButton(
                    title: kind.title,
                    isSelected: modelView.instrument == kind
                ) {
                    modelView.selectInstrument(kind)
                }
            }
        }
    }

    private var presetButton: some View {
        Button {
            modelView.showsTuningSheet = true
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
        HStack(spacing: 10) {
            ForEach(TunerMode.allCases, id: \.self) { mode in
                ChipButton(
                    title: mode.title,
                    isSelected: modelView.mode == mode
                ) {
                    modelView.selectMode(mode)
                }
            }
            Spacer()
        }
    }
}
