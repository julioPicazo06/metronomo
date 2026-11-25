import UIKit

// MARK: - HapticPlayer
// UIImpactFeedbackGenerator. Gated by AppSettingsStore.hapticsEnabled in the ModelViews.

final class HapticPlayer: HapticPlaying {
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)

    func playInTune() {
        medium.impactOccurred()
    }

    func playClick(isAccent: Bool) {
        if isAccent {
            medium.impactOccurred(intensity: 1)
        } else {
            light.impactOccurred(intensity: 0.7)
        }
    }
}
