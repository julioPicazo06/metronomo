import Foundation
import Testing
@testable import afinador

// MARK: - Tempo / MetronomeModelView / settings persistence / YIN tests

struct TempoTests {
    @Test func clampsToRange() {
        #expect(Tempo(bpm: 10).bpm == 30)
        #expect(Tempo(bpm: 400).bpm == 300)
        #expect(Tempo(bpm: 120).bpm == 120)
    }

    @Test func incrementAndDecrementStayInRange() {
        var tempo = Tempo(bpm: 300)
        tempo.increment()
        #expect(tempo.bpm == 300)
        tempo = Tempo(bpm: 30)
        tempo.decrement()
        #expect(tempo.bpm == 30)
    }

    @Test func tapIntervalsEstimateBPM() {
        let tempo = Tempo.fromTapIntervals([0.5, 0.5, 0.5])
        #expect(tempo?.bpm == 120)
    }
}

struct MetronomeModelViewTests {
    private func makeStore() -> AppSettingsStore {
        AppSettingsStore(defaults: UserDefaults(suiteName: "tests.metro.\(UUID().uuidString)")!)
    }

    @Test func playStartsPlayer() {
        let player = FakeClickPlayer()
        let modelView = MetronomeModelView(player: player, haptics: FakeHaptics(), settings: makeStore())
        modelView.togglePlay()
        #expect(modelView.isPlaying)
        #expect(player.isRunning)
        #expect(player.lastBPM == 120)
        modelView.togglePlay()
        #expect(modelView.isPlaying == false)
        #expect(player.isRunning == false)
    }

    @Test func tapTempoUpdatesBPM() {
        let modelView = MetronomeModelView(player: FakeClickPlayer(), haptics: FakeHaptics(), settings: makeStore())
        let t0 = Date(timeIntervalSince1970: 1_000)
        modelView.tap(now: t0)
        modelView.tap(now: t0.addingTimeInterval(0.5))
        modelView.tap(now: t0.addingTimeInterval(1.0))
        #expect(modelView.bpm == 120)
        #expect(modelView.isTapping)
    }

    @Test func tapGapResetStartsNewEstimate() {
        let modelView = MetronomeModelView(player: FakeClickPlayer(), haptics: FakeHaptics(), settings: makeStore())
        let t0 = Date(timeIntervalSince1970: 2_000)
        modelView.tap(now: t0)
        modelView.tap(now: t0.addingTimeInterval(0.5))
        #expect(modelView.bpm == 120)
        // Gap > reset interval clears buffer; single new tap alone cannot change BPM.
        modelView.tap(now: t0.addingTimeInterval(0.5 + MetronomeModelView.tapGapResetInterval + 0.1))
        #expect(modelView.bpm == 120)
        modelView.tap(now: t0.addingTimeInterval(0.5 + MetronomeModelView.tapGapResetInterval + 0.1 + 0.4))
        #expect(modelView.bpm == 150)
    }

    @Test func tapTempoUsesNamedIntervals() {
        #expect(MetronomeModelView.tapGapResetInterval == 2)
        #expect(MetronomeModelView.tapIndicatorClearInterval == 1.2)
        #expect(MetronomeModelView.tapIndicatorClearNanoseconds == 1_200_000_000)
    }
}

struct AppSettingsStoreTests {
    @Test func persistsA4AndThreshold() {
        let suite = "tests.settings.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let store = AppSettingsStore(defaults: defaults)
        store.a4Frequency = 432
        store.inTuneThreshold = 3
        store.metronomeSound = .wood

        let reloaded = AppSettingsStore(defaults: defaults)
        #expect(reloaded.a4Frequency == 432)
        #expect(reloaded.inTuneThreshold == 3)
        #expect(reloaded.metronomeSound == .wood)
    }

    @Test func persistsSingleInstrumentPreference() {
        let suite = "tests.settings.instrument.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let store = AppSettingsStore(defaults: defaults)
        store.defaultInstrument = .bass5

        let reloaded = AppSettingsStore(defaults: defaults)
        #expect(reloaded.defaultInstrument == .bass5)
    }

    @Test func migratesLegacyInstrumentKey() {
        let suite = "tests.settings.legacyInstrument.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set("bass", forKey: "afinador.settings.instrument")

        let store = AppSettingsStore(defaults: defaults)
        #expect(store.defaultInstrument == .bass4)
    }

    @Test func rejectsInvalidA4AndThresholdOnLoad() {
        let suite = "tests.settings.sanitize.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set(415.0, forKey: "afinador.settings.a4")
        defaults.set(7.0, forKey: "afinador.settings.threshold")

        let store = AppSettingsStore(defaults: defaults)
        #expect(store.a4Frequency == 440)
        #expect(store.inTuneThreshold == 5)
    }

    @Test func settersSanitizeA4AndThreshold() {
        let suite = "tests.settings.sanitizeSet.\(UUID().uuidString)"
        let store = AppSettingsStore(defaults: UserDefaults(suiteName: suite)!)
        store.a4Frequency = 400
        store.inTuneThreshold = 99
        #expect(store.a4Frequency == 440)
        #expect(store.inTuneThreshold == 5)
        store.a4Frequency = 442
        store.inTuneThreshold = 3
        #expect(store.a4Frequency == 442)
        #expect(store.inTuneThreshold == 3)
    }
}

struct PitchEstimatorTests {
    @Test func detects440Sine() {
        let sampleRate = 44_100.0
        let frequency = 440.0
        let count = 4096
        let samples: [Float] = (0..<count).map { index in
            Float(sin(2 * Double.pi * frequency * Double(index) / sampleRate))
        }
        let detected = PitchEstimator.frequency(samples: samples, sampleRate: sampleRate)
        #expect(detected != nil)
        #expect(abs((detected ?? 0) - 440) < 3)
    }
}
