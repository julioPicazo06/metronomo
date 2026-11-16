import Foundation

// MARK: - PitchClass (Model)
// 12-tone class. `name` uses ♯ for the big readout; `chipName` uses ASCII # for chips.

enum PitchClass: Int, CaseIterable, Sendable, Equatable {
    case c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b

    var name: String {
        switch self {
        case .c: "C"
        case .cSharp: "C♯"
        case .d: "D"
        case .dSharp: "D♯"
        case .e: "E"
        case .f: "F"
        case .fSharp: "F♯"
        case .g: "G"
        case .gSharp: "G♯"
        case .a: "A"
        case .aSharp: "A♯"
        case .b: "B"
        }
    }

    var chipName: String {
        switch self {
        case .cSharp: "C#"
        case .dSharp: "D#"
        case .fSharp: "F#"
        case .gSharp: "G#"
        case .aSharp: "A#"
        default: name
        }
    }
}

// MARK: - Note (Model)
// Pitch + octave. Frequency: A4 * 2^((midi-69)/12). MIDI A4 = 69.
// Debug: cents = 1200 * log2(detected / target). 0 = in tune, + = sharp, − = flat.

struct Note: Equatable, Hashable, Sendable {
    let pitchClass: PitchClass
    let octave: Int

    var midi: Int {
        (octave + 1) * 12 + pitchClass.rawValue
    }

    var displayName: String { pitchClass.name }

    var chipLabel: String { "\(pitchClass.chipName)\(octave)" }

    func frequency(a4: Double = 440) -> Double {
        a4 * pow(2.0, Double(midi - 69) / 12.0)
    }

    func cents(from detectedFrequency: Double, a4: Double = 440) -> Double {
        1200 * log2(detectedFrequency / frequency(a4: a4))
    }

    static func from(midi: Int) -> Note {
        let wrapped = ((midi % 12) + 12) % 12
        let pitchClass = PitchClass(rawValue: wrapped) ?? .c
        let octave = midi / 12 - 1
        return Note(pitchClass: pitchClass, octave: octave)
    }

    static func closest(to frequency: Double, a4: Double = 440) -> Note {
        let midi = Int((69 + 12 * log2(frequency / a4)).rounded())
        return from(midi: midi)
    }

    static func closest(to frequency: Double, among notes: [Note], a4: Double = 440) -> (note: Note, index: Int) {
        var bestIndex = 0
        var bestDistance = Double.greatestFiniteMagnitude
        for (index, note) in notes.enumerated() {
            let distance = abs(log2(frequency / note.frequency(a4: a4)))
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }
        return (notes[bestIndex], bestIndex)
    }
}
