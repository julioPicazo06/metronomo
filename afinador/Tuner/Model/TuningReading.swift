import Foundation

// MARK: - TunerStatus (Model)
// UI state machine. idle = rest note on screen, no live pitch.
// noMicrophone / unavailable hide live Hz and show TunerMicPermissionView.

enum TunerStatus: Equatable, Sendable {
    case idle
    case listening
    case inTune
    case sharp
    case flat
    case noMicrophone
    case unavailable
}

// MARK: - TuningReading (Model)
// One analysis frame: closest note, Hz, cents, optional string index.

struct TuningReading: Equatable, Sendable {
    let note: Note
    let frequency: Double
    let cents: Double
    let stringIndex: Int?

    func status(threshold: Double) -> TunerStatus {
        if abs(cents) <= threshold {
            return .inTune
        }
        return cents > 0 ? .sharp : .flat
    }
}

// MARK: - TuningAnalyzer (Model)
// Pure function: frequency + mode + strings → TuningReading. No audio, easy to unit-test.

enum TuningAnalyzer {
    static func reading(
        frequency: Double,
        mode: TunerMode,
        strings: [Note],
        lockedStringIndex: Int?,
        a4: Double,
        threshold: Double
    ) -> TuningReading {
        switch mode {
        case .chromatic:
            let note = Note.closest(to: frequency, a4: a4)
            return TuningReading(
                note: note,
                frequency: frequency,
                cents: note.cents(from: frequency, a4: a4),
                stringIndex: nil
            )
        case .strings:
            let index: Int
            let note: Note
            if let lockedStringIndex, strings.indices.contains(lockedStringIndex) {
                index = lockedStringIndex
                note = strings[lockedStringIndex]
            } else {
                let closest = Note.closest(to: frequency, among: strings, a4: a4)
                index = closest.index
                note = closest.note
            }
            return TuningReading(
                note: note,
                frequency: frequency,
                cents: note.cents(from: frequency, a4: a4),
                stringIndex: index
            )
        }
    }
}
