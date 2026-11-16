import Foundation
@testable import afinador

// MARK: - Test doubles
// Same ports as production audio, no hardware. emit(_:) simulates a detected frequency.

final class FakePitchDetector: PitchDetecting {
    var onFrequency: ((Double) -> Void)?
    private(set) var started = false
    private(set) var startError: Error?

    func start() throws {
        if let startError {
            throw startError
        }
        started = true
    }

    func stop() {
        started = false
    }

    func emit(_ frequency: Double) {
        onFrequency?(frequency)
    }
}

final class FakeMicrophonePermission: MicrophonePermitting {
    var status: MicrophoneStatus

    init(_ status: MicrophoneStatus) {
        self.status = status
    }

    func currentStatus() -> MicrophoneStatus {
        status
    }

    func requestAccess() async -> MicrophoneStatus {
        status
    }
}

final class FakeSystemOpener: SystemOpening {
    private(set) var didOpenSettings = false

    func openAppSettings() {
        didOpenSettings = true
    }
}

final class FakeHaptics: HapticPlaying {
    private(set) var inTuneCount = 0
    private(set) var clickCount = 0

    func playInTune() {
        inTuneCount += 1
    }

    func playClick(isAccent: Bool) {
        clickCount += 1
    }
}

final class FakeClickPlayer: ClickPlaying {
    private(set) var isRunning = false
    private(set) var lastBPM: Int?
    private(set) var lastBeats: Int?
    private(set) var lastClicksPerBeat: Int?
    private(set) var lastSound: ClickSound?
    var onBeat: ((Int, Bool) -> Void)?

    func start(
        bpm: Int,
        beatsPerMeasure: Int,
        clicksPerBeat: Int,
        sound: ClickSound,
        onBeat: @escaping (Int, Bool) -> Void
    ) {
        isRunning = true
        lastBPM = bpm
        lastBeats = beatsPerMeasure
        lastClicksPerBeat = clicksPerBeat
        lastSound = sound
        self.onBeat = onBeat
    }

    func stop() {
        isRunning = false
    }

    func update(bpm: Int, beatsPerMeasure: Int, clicksPerBeat: Int, sound: ClickSound) {
        lastBPM = bpm
        lastBeats = beatsPerMeasure
        lastClicksPerBeat = clicksPerBeat
        lastSound = sound
    }

    func emitBeat(_ beat: Int, isAccent: Bool = false) {
        onBeat?(beat, isAccent)
    }
}
