import Testing
@testable import afinador

// MARK: - Smoke
// Confirms the app module imports. Domain tests live under Tuner/ and Metronome/.

struct afinadorTests {
    @Test func moduleLoads() {
        #expect(AppSettings.default.a4Frequency == 440)
    }
}
