import SwiftUI

// MARK: - AppTheme
// Monokai-Soft-MD tokens from the Xcode theme (dark only).
// Debug: canvas #10171B, accent #F92672, numeric #A6A9EE, success #A3D53E, note gold #EECA4E.

enum AppTheme {
    static let canvas = Color(hex: 0x10171B)
    static let surface = Color(hex: 0x1E282D)
    static let chrome = Color(hex: 0x263238)
    static let textPrimary = Color(hex: 0xB1BFC2)
    static let textMuted = Color(hex: 0x696D75)
    static let border = Color(hex: 0x65737E)
    static let numeric = Color(hex: 0xA6A9EE)
    static let emphasis = Color(hex: 0xEECA4E)
    static let accent = Color(hex: 0xF92672)
    static let success = Color(hex: 0xA3D53E)
    static let successAlt = Color(hex: 0x8FCA3C)
    static let info = Color(hex: 0x6DCEE0)
    static let selection = Color(hex: 0x7ACACB)
    static let warning = Color(hex: 0xEE7F17)
    static let danger = Color(hex: 0xD54A36)
    static let caret = Color(hex: 0xFFCC00)
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
