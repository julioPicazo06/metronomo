import SwiftUI

// MARK: - SettingsView (View canvas)
// Rows stay here (only used on this screen). Sheets are Shared/UI.
// Debug: A4/threshold affect next tuner ingest. Sound → ClickPlayer via AppSettingsStore.

struct SettingsView: View {
    let modelView: SettingsModelView

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(SettingsCopy.Screen.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text(SettingsCopy.Screen.sectionTuner)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.success)
                    .padding(.top, 4)

                settingsButton(SettingsCopy.Row.a4, value: AppCopy.Format.hzInt(modelView.store.a4Frequency)) {
                    modelView.showsA4Sheet = true
                }
                settingsButton(SettingsCopy.Row.threshold, value: AppCopy.Format.centsThreshold(modelView.store.inTuneThreshold)) {
                    modelView.showsThresholdSheet = true
                }
                settingsButton(SettingsCopy.Row.defaultInstrument, value: modelView.store.defaultInstrument.title, valueColor: AppTheme.emphasis) {
                    modelView.showsInstrumentSheet = true
                }

                toggleRow(SettingsCopy.Row.keepAwake, isOn: Binding(
                    get: { modelView.store.keepScreenAwake },
                    set: { modelView.store.keepScreenAwake = $0 }
                ))
                toggleRow(SettingsCopy.Row.haptics, isOn: Binding(
                    get: { modelView.store.hapticsEnabled },
                    set: { modelView.store.hapticsEnabled = $0 }
                ))
                settingsButton(SettingsCopy.Row.metronomeSound, value: modelView.store.metronomeSound.title, valueColor: AppTheme.emphasis) {
                    modelView.showsSoundSheet = true
                }

                Text(modelView.versionText)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .sheet(isPresented: Binding(get: { modelView.showsA4Sheet }, set: { modelView.showsA4Sheet = $0 })) {
            OptionPickerSheet(
                title: SettingsCopy.Row.a4,
                options: AppSettings.a4Options.map { (AppCopy.Format.hzInt($0), $0) },
                selected: modelView.store.a4Frequency,
                onSelect: modelView.selectA4
            )
        }
        .sheet(isPresented: Binding(get: { modelView.showsThresholdSheet }, set: { modelView.showsThresholdSheet = $0 })) {
            OptionPickerSheet(
                title: SettingsCopy.Row.thresholdSheet,
                options: AppSettings.thresholdOptions.map { (AppCopy.Format.centsThreshold($0), $0) },
                selected: modelView.store.inTuneThreshold,
                onSelect: modelView.selectThreshold
            )
        }
        .sheet(isPresented: Binding(get: { modelView.showsInstrumentSheet }, set: { modelView.showsInstrumentSheet = $0 })) {
            OptionPickerSheet(
                title: SettingsCopy.Row.instrumentSheet,
                options: InstrumentKind.allCases.map { ($0.title, $0) },
                selected: modelView.store.defaultInstrument,
                onSelect: modelView.selectInstrument
            )
        }
        .sheet(isPresented: Binding(get: { modelView.showsSoundSheet }, set: { modelView.showsSoundSheet = $0 })) {
            SoundPickerSheet(selected: modelView.store.metronomeSound) { sound in
                modelView.selectSound(sound)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: Row helpers
    // Local to Settings. Value strings are display-only; store is the source of truth.

    private func settingsButton(_ title: String, value: String, valueColor: Color = AppTheme.numeric, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundStyle(.white)
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(valueColor)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.surface)
            )
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .foregroundStyle(.white)
        }
        .tint(AppTheme.success)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.surface)
        )
    }
}
