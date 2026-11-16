import Foundation

// MARK: - TimeSignature (Model)
// Beats per bar for pulse dots and ClickPlayer.beatsPerMeasure.

enum TimeSignature: String, CaseIterable, Sendable, Equatable {
    case twoFour
    case threeFour
    case fourFour
    case sixEight

    var beats: Int {
        switch self {
        case .twoFour: 2
        case .threeFour: 3
        case .fourFour: 4
        case .sixEight: 6
        }
    }

    var label: String {
        MetronomeCopy.Signature.label(for: self)
    }
}

// MARK: - Subdivision (Model)
// Extra clicks inside one beat. clicksPerBeat drives the audio scheduler, not the dots.

enum Subdivision: String, CaseIterable, Sendable, Equatable {
    case quarter
    case eighth
    case triplet
    case sixteenth

    var clicksPerBeat: Int {
        switch self {
        case .quarter: 1
        case .eighth: 2
        case .triplet: 3
        case .sixteenth: 4
        }
    }

    var title: String {
        MetronomeCopy.SubdivisionLabel.title(for: self)
    }

    var symbolName: String {
        switch self {
        case .quarter: "music.note"
        case .eighth: "music.note.list"
        case .triplet: "metronome"
        case .sixteenth: "music.quarternote.3"
        }
    }
}

// MARK: - ClickSound (Model)
// Synthesized by ClickEngine (sine burst). mute = visual + haptic only.

enum ClickSound: String, CaseIterable, Sendable, Equatable {
    case click
    case wood
    case beep
    case mute

    var title: String {
        MetronomeCopy.Sound.title(for: self)
    }
}
