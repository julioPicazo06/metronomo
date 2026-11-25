import Foundation

// MARK: - TunerCopy
// All Tuner screen strings. Views must not hardcode Spanish copy.

enum TunerCopy {
    enum Screen {
        static let title = "Afinador"
        static let chromaticHint = "Detección cromática automática"
    }

    enum Status {
        static let idle = "Toca una cuerda"
        static let inTune = "Afinada"
        static let sharp = "Un poco alta"
        static let flat = "Un poco baja"
    }

    enum Mic {
        static let disabled = "Micrófono desactivado"
        static let inUse = "Micrófono en uso"
        static let hint = "Activa el micrófono para afinar."
        static let openSettings = "Abrir Ajustes de iOS"
    }

    enum Gauge {
        static let minus50 = "−50"
        static let plus50 = "+50"
        static let accessibilityNeedle = "Aguja de cents"
    }

    enum Preset {
        static let standard = "Estándar"
        static let dropD = "Drop D"
        static let openG = "Open G"
        static let openD = "Open D"
        static let dropA = "Drop A"
        static let ukuleleC = "C"
        static let ukuleleD = "D"
        static let baritone = "Barítono"

        static func sheetTitle(instrument: String) -> String {
            "Afinación · \(instrument)"
        }

        static func row(name: String, summary: String) -> String {
            "\(name) (\(summary))"
        }
    }

    enum Instrument {
        static let sheetTitle = "Instrumento"
        static let guitar = "Guitarra"
        static let bass4 = "Bajo 4 cuerdas"
        static let bass5 = "Bajo 5 cuerdas"
        static let violin = "Violín"
        static let ukulele = "Ukelele"

        static func title(for kind: InstrumentKind) -> String {
            switch kind {
            case .guitar: guitar
            case .bass4: bass4
            case .bass5: bass5
            case .violin: violin
            case .ukulele: ukulele
            }
        }
    }

    enum Mode {
        static let strings = "Cuerdas"
        static let chromatic = "Cromático"

        static func title(for mode: TunerMode) -> String {
            switch mode {
            case .strings: strings
            case .chromatic: chromatic
            }
        }
    }
}
