import Foundation

// MARK: - TuningPreset catalog (data)
// Open-string tables per instrument. Types live in Instrument.swift.

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

    static let bass4: [TuningPreset] = [
        TuningPreset(
            id: "bass4.standard",
            name: TunerCopy.Preset.standard,
            strings: [
                Note(pitchClass: .e, octave: 1),
                Note(pitchClass: .a, octave: 1),
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .g, octave: 2)
            ]
        ),
        TuningPreset(
            id: "bass4.dropD",
            name: TunerCopy.Preset.dropD,
            strings: [
                Note(pitchClass: .d, octave: 1),
                Note(pitchClass: .a, octave: 1),
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .g, octave: 2)
            ]
        )
    ]

    static let bass5: [TuningPreset] = [
        TuningPreset(
            id: "bass5.standard",
            name: TunerCopy.Preset.standard,
            strings: [
                Note(pitchClass: .b, octave: 0),
                Note(pitchClass: .e, octave: 1),
                Note(pitchClass: .a, octave: 1),
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .g, octave: 2)
            ]
        ),
        TuningPreset(
            id: "bass5.dropA",
            name: TunerCopy.Preset.dropA,
            strings: [
                Note(pitchClass: .a, octave: 0),
                Note(pitchClass: .e, octave: 1),
                Note(pitchClass: .a, octave: 1),
                Note(pitchClass: .d, octave: 2),
                Note(pitchClass: .g, octave: 2)
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
