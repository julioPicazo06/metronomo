import Foundation

// MARK: - Audio ports (injected by Controllers, faked in tests)
// PitchDetecting: start/stop + onFrequency callback (Hz).
// MicrophonePermitting: AVAudioApplication permission.
// SystemOpening: deep-link to iOS Settings.
// HapticPlaying: in-tune bump + metronome ticks.

enum MicrophoneStatus: Equatable, Sendable {
    case granted
    case denied
    case undetermined
    case unavailable
}

protocol MicrophonePermitting: AnyObject {
    func currentStatus() -> MicrophoneStatus
    func requestAccess() async -> MicrophoneStatus
}

protocol PitchDetecting: AnyObject {
    var onFrequency: ((Double) -> Void)? { get set }
    func start() throws
    func stop()
}

protocol SystemOpening: AnyObject {
    func openAppSettings()
}

protocol HapticPlaying: AnyObject {
    func playInTune()
    func playClick(isAccent: Bool)
}
