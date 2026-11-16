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
        modelView.tap()
        Thread.sleep(forTimeInterval: 0.5)
        modelView.tap()
        Thread.sleep(forTimeInterval: 0.5)
        modelView.tap()
        #expect((100...140).contains(modelView.bpm))
        #expect(modelView.isTapping)
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
