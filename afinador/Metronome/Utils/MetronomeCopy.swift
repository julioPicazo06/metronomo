import Foundation

// MARK: - MetronomeCopy
// All Metronome screen strings. Views must not hardcode Spanish copy.

enum MetronomeCopy {
    enum Screen {
        static let title = "Metrónomo"
        static let bpm = "BPM"
        static let signature = "Compás"
        static let subdivision = "Subdivisión"
        static let pulses = "Pulsos"
        static let soundAccessibility = "Sonido del clic"
        static let soundSheetTitle = "Sonido del clic"
    }

    enum Controls {
        static let tap = "Tap"
        static let tapTempo = "Tap tempo"
        static let tapping = "Marcando..."
        static let play = "Play"
        static let stop = "Stop"
    }

    enum Signature {
        static let twoFour = "2/4"
        static let threeFour = "3/4"
        static let fourFour = "4/4"
        static let sixEight = "6/8"

        static func label(for signature: TimeSignature) -> String {
            switch signature {
            case .twoFour: twoFour
            case .threeFour: threeFour
            case .fourFour: fourFour
            case .sixEight: sixEight
            }
        }
    }

    enum SubdivisionLabel {
        static let quarter = "Negra"
        static let eighth = "Corchea"
        static let triplet = "Tresillo"
        static let sixteenth = "Semicorchea"
        static let tripletBadge = "3"

        static func title(for subdivision: Subdivision) -> String {
            switch subdivision {
            case .quarter: quarter
            case .eighth: eighth
            case .triplet: triplet
            case .sixteenth: sixteenth
            }
        }
    }

    enum Sound {
        static let click = "Click"
        static let wood = "Madera"
        static let beep = "Beep"
        static let mute = "Silencio (solo visual)"

        static func title(for sound: ClickSound) -> String {
            switch sound {
            case .click: click
            case .wood: wood
            case .beep: beep
            case .mute: mute
            }
        }
    }
}
