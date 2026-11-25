import AVFoundation
import Foundation

// MARK: - MicrophonePermission
// iOS 17+ AVAudioApplication.recordPermission. Injected into TunerModelView.

final class MicrophonePermission: MicrophonePermitting {
    func currentStatus() -> MicrophoneStatus {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .undetermined
        @unknown default:
            return .denied
        }
    }

    func requestAccess() async -> MicrophoneStatus {
        let granted = await AVAudioApplication.requestRecordPermission()
        return granted ? .granted : .denied
    }
}
