import Foundation

// MARK: - AppCopy
// Shared UI strings and formatters. Feature-specific copy lives in TunerCopy / MetronomeCopy / SettingsCopy.

enum AppCopy {
    enum Tab {
        static let tuner = "Afinador"
        static let metronome = "Metrónomo"
        static let settings = "Ajustes"
    }

    enum Format {
        static func hz(_ value: Double) -> String {
            String(format: "%.1f Hz", value)
        }

        static func hzInt(_ value: Double) -> String {
            "\(Int(value)) Hz"
        }

        static func cents(_ value: Double) -> String {
            let rounded = value.rounded()
            if rounded == 0 { return "0 cents" }
            return String(format: "%+.0f cents", rounded)
        }

        static func centsThreshold(_ value: Double) -> String {
            "±\(Int(value)) cents"
        }
    }
}
