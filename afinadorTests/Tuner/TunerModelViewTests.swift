import Foundation
import Testing
@testable import afinador

// MARK: - TunerModelView tests
// Idle must still show E2. Denied mic → noMicrophone and detector not started.

struct TunerModelViewTests {
    private func makeStore() -> AppSettingsStore {
        AppSettingsStore(defaults: UserDefaults(suiteName: "tests.tuner.\(UUID().uuidString)")!)
    }

    private func makeModelView(
        detector: FakePitchDetector = FakePitchDetector(),
        permission: FakeMicrophonePermission = FakeMicrophonePermission(.granted),
        opener: FakeSystemOpener = FakeSystemOpener(),
        haptics: FakeHaptics = FakeHaptics(),
        settings: AppSettingsStore? = nil
    ) -> (TunerModelView, FakePitchDetector, FakeHaptics) {
        let store = settings ?? makeStore()
        let modelView = TunerModelView(
            detector: detector,
            permission: permission,
            opener: opener,
            haptics: haptics,
            settings: store
        )
        return (modelView, detector, haptics)
    }

    @Test func startsIdleOnGuitar() {
        let (modelView, _, _) = makeModelView()
        #expect(modelView.status == .idle)
        #expect(modelView.instrument == .guitar)
        #expect(modelView.strings.count == 6)
        #expect(modelView.displayedNote.pitchClass == .e)
        #expect(modelView.displayedNote.octave == 2)
        #expect(modelView.displayedCents == 0)
        #expect(modelView.highlightedStringIndex == 0)
        #expect(modelView.hasSignal == false)
    }

    @Test func appearStartsDetectorWhenMicGranted() async {
        let detector = FakePitchDetector()
        let (modelView, _, _) = makeModelView(detector: detector)
        modelView.appear()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(detector.started)
    }

    @Test func deniedMicrophoneShowsNoMic() async {
        let (modelView, detector, _) = makeModelView(permission: FakeMicrophonePermission(.denied))
        modelView.appear()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(modelView.status == .noMicrophone)
        #expect(detector.started == false)
    }

    @Test func ingesting440InChromaticShowsA4() {
        let (modelView, detector, _) = makeModelView()
        modelView.selectMode(.chromatic)
        detector.emit(440)
        #expect(modelView.displayedNote.pitchClass == .a)
        #expect(modelView.displayedNote.octave == 4)
        #expect(modelView.status == .inTune)
    }

    @Test func ingestingGuitarEHighlightsFirstString() {
        let (modelView, detector, _) = makeModelView()
        let e2 = Note(pitchClass: .e, octave: 2).frequency(a4: 440)
        detector.emit(e2)
        #expect(modelView.highlightedStringIndex == 0)
        #expect(modelView.status == .inTune)
    }

    @Test func switchingInstrumentChangesStringCount() {
        let (modelView, _, _) = makeModelView()
        modelView.selectInstrument(.bass4)
        #expect(modelView.strings.count == 4)
        #expect(modelView.instrument == .bass4)
        modelView.selectInstrument(.bass5)
        #expect(modelView.strings.count == 5)
        #expect(modelView.instrument == .bass5)
        modelView.selectInstrument(.violin)
        #expect(modelView.strings.count == 4)
        #expect(modelView.instrument == .violin)
        modelView.selectInstrument(.ukulele)
        #expect(modelView.strings.count == 4)
    }

    @Test func selectInstrumentPersistsOnlyDefaultInstrument() {
        let store = makeStore()
        let (modelView, _, _) = makeModelView(settings: store)
        modelView.selectInstrument(.ukulele)
        #expect(store.defaultInstrument == .ukulele)
        #expect(modelView.instrument == .ukulele)
    }

    @Test func appearReadsDefaultInstrument() {
        let store = makeStore()
        store.defaultInstrument = .violin
        let (modelView, _, _) = makeModelView(settings: store)
        modelView.appear()
        #expect(modelView.instrument == .violin)
        #expect(modelView.strings.count == 4)
    }

    @Test func ingestingSharpSetsSharpStatus() {
        let (modelView, detector, _) = makeModelView()
        modelView.selectMode(.chromatic)
        detector.emit(445)
        #expect(modelView.status == .sharp)
    }

    @Test func ingestingFlatSetsFlatStatus() {
        let (modelView, detector, _) = makeModelView()
        modelView.selectMode(.chromatic)
        detector.emit(435)
        #expect(modelView.status == .flat)
    }

    @Test func hapticFiresOnlyOnTransitionToInTune() {
        let haptics = FakeHaptics()
        let (modelView, detector, _) = makeModelView(haptics: haptics)
        modelView.selectMode(.chromatic)
        detector.emit(440)
        #expect(haptics.inTuneCount == 1)
        detector.emit(440)
        #expect(haptics.inTuneCount == 1)
        detector.emit(445)
        detector.emit(440)
        #expect(haptics.inTuneCount == 2)
    }

    @Test func hapticSkippedWhenDisabled() {
        let store = makeStore()
        store.hapticsEnabled = false
        let haptics = FakeHaptics()
        let (modelView, detector, _) = makeModelView(haptics: haptics, settings: store)
        modelView.selectMode(.chromatic)
        detector.emit(440)
        #expect(modelView.status == .inTune)
        #expect(haptics.inTuneCount == 0)
    }

    @Test func returnsToIdleAfterSilence() async {
        let (modelView, detector, _) = makeModelView()
        modelView.selectMode(.chromatic)
        detector.emit(440)
        #expect(modelView.status == .inTune)
        #expect(modelView.hasSignal)
        let waitNanos = TunerModelView.idleResetNanoseconds + 150_000_000
        try? await Task.sleep(nanoseconds: waitNanos)
        #expect(modelView.status == .idle)
        #expect(modelView.reading == nil)
        #expect(modelView.hasSignal == false)
    }

    @Test func idleResetUsesSingleInterval() {
        #expect(TunerModelView.idleResetInterval == 0.85)
        #expect(TunerModelView.idleResetNanoseconds == 850_000_000)
    }
}
