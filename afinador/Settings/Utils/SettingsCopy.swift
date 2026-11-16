import Foundation

// MARK: - SettingsCopy
// All Settings screen strings. Views must not hardcode Spanish copy.

enum SettingsCopy {
    enum Screen {
        static let title = "Ajustes"
        static let sectionTuner = "AFINADOR"
    }

    enum Row {
        static let a4 = "Referencia A4"
        static let threshold = "Umbral «afinada»"
        static let thresholdSheet = "Umbral afinada"
        static let defaultInstrument = "Instrumento predeterminado"
        static let instrumentSheet = "Instrumento"
        static let keepAwake = "Mantener pantalla encendida"
        static let haptics = "Vibración háptica"
        static let metronomeSound = "Sonido del metrónomo"
    }

    enum Version {
        static let fallback = "1.0.0"

        static func label(version: String) -> String {
            "afinador · versión \(version)"
        }
    }
}
