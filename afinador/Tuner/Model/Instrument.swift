import Foundation

// MARK: - InstrumentKind (Model)
// Guitar / violin / ukulele. Presets live on TuningPreset; this enum only picks the list.

enum InstrumentKind: String, CaseIterable, Sendable, Equatable {
    case guitar
    case violin
    case ukulele

    var title: String {
        TunerCopy.Instrument.title(for: self)
    }

    var presets: [TuningPreset] {
        switch self {
        case .guitar: TuningPreset.guitar
        case .violin: TuningPreset.violin
        case .ukulele: TuningPreset.ukulele
        }
    }

    var defaultPreset: TuningPreset {
        presets[0]
    }
}

// MARK: - TuningPreset (Model)
// Open-string list for one tuning. id prefix is the instrument rawValue (guitar.standard).

struct TuningPreset: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let strings: [Note]

    var summary: String {
        strings.map(\.pitchClass.chipName).joined(separator: " ")
    }
}

extension TuningPreset {
    static let guitar: [TuningPreset] = [
        TuningPreset(
            id: "guitar.standard",
            name: TunerCopy.Preset.standard,
            strings: [
                Note(pitchClass: .e, octave: 2),
                Note(pitchClass: .a, octave: 2),
                Note(pitchClass: .d, octave: 3),
                Note(pitchClass: .g, octave: 3),
                Note(pitchClass: .b, octave: 3),
                Note(pitchClass: .e, octave: 4)
            ]
        ),
        TuningPreset(
            id: "guitar.dropD",
            name: TunerCopy.Preset.dropD,
            strings: [
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .a, octave: 2),
                Note(pitchClass: .d, octave: 3),
                Note(pitchClass: .g, octave: 3),
                Note(pitchClass: .b, octave: 3),
                Note(pitchClass: .e, octave: 4)
            ]
        ),
        TuningPreset(
            id: "guitar.openG",
            name: TunerCopy.Preset.openG,
            strings: [
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .g, octave: 2),
                Note(pitchClass: .d, octave: 3),
                Note(pitchClass: .g, octave: 3),
                Note(pitchClass: .b, octave: 3),
                Note(pitchClass: .d, octave: 4)
            ]
        ),
        TuningPreset(
            id: "guitar.openD",
            name: TunerCopy.Preset.openD,
            strings: [
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .a, octave: 2),
                Note(pitchClass: .d, octave: 3),
                Note(pitchClass: .fSharp, octave: 3),
                Note(pitchClass: .a, octave: 3),
                Note(pitchClass: .d, octave: 4)
            ]
        )
    ]

    static let violin: [TuningPreset] = [
        TuningPreset(
            id: "violin.standard",
            name: TunerCopy.Preset.standard,
            strings: [
                Note(pitchClass: .g, octave: 3),
                Note(pitchClass: .d, octave: 4),
                Note(pitchClass: .a, octave: 4),
                Note(pitchClass: .e, octave: 5)
            ]
        )
    ]

    static let ukulele: [TuningPreset] = [
        TuningPreset(
            id: "ukulele.c",
            name: TunerCopy.Preset.ukuleleC,
            strings: [
                Note(pitchClass: .g, octave: 4),
                Note(pitchClass: .c, octave: 4),
                Note(pitchClass: .e, octave: 4),
                Note(pitchClass: .a, octave: 4)
            ]
        ),
        TuningPreset(
            id: "ukulele.d",
            name: TunerCopy.Preset.ukuleleD,
            strings: [
                Note(pitchClass: .a, octave: 4),
                Note(pitchClass: .d, octave: 4),
                Note(pitchClass: .fSharp, octave: 4),
                Note(pitchClass: .b, octave: 4)
            ]
        ),
        TuningPreset(
            id: "ukulele.baritone",
            name: TunerCopy.Preset.baritone,
            strings: [
                Note(pitchClass: .d, octave: 3),
                Note(pitchClass: .g, octave: 3),
                Note(pitchClass: .b, octave: 3),
                Note(pitchClass: .e, octave: 4)
            ]
        )
    ]
}

// MARK: - TunerMode (Model)
// strings = snap to nearest open string. chromatic = nearest 12-TET note.

enum TunerMode: String, CaseIterable, Sendable, Equatable {
    case strings
    case chromatic

    var title: String {
        TunerCopy.Mode.title(for: self)
    }
}
