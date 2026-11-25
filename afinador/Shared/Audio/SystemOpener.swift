import Foundation
import UIKit

// MARK: - SystemOpener
// Deep-links to the iOS Settings app (mic permission recovery).

final class SystemOpener: SystemOpening {
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
