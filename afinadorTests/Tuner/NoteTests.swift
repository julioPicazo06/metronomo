import Foundation
import Testing
@testable import afinador

// MARK: - Note + TuningAnalyzer tests
// Pure Model — no mic. If A4≠440 or E2 isn't ~82.4 Hz, the tuner math is wrong.

struct NoteTests {
    @Test func a4Is440() {
        let note = Note(pitchClass: .a, octave: 4)
        #expect(note.displayName == "A")
        #expect(note.octave == 4)
        #expect(abs(note.frequency(a4: 440) - 440) < 0.0001)
    }

    @Test func centsAtTargetIsZero() {
        let a4 = Note(pitchClass: .a, octave: 4)
        #expect(a4.cents(from: 440) == 0)
    }

    @Test func closestTo440IsA4() {
        let note = Note.closest(to: 440)
        #expect(note.pitchClass == .a)
        #expect(note.octave == 4)
    }

    @Test func e2FrequencyIsAbout82() {
        let e2 = Note(pitchClass: .e, octave: 2)
        #expect(abs(e2.frequency(a4: 440) - 82.41) < 0.1)
    }

    @Test func guitarStandardHasSixStrings() {
        #expect(TuningPreset.guitar[0].strings.count == 6)
        #expect(TuningPreset.violin[0].strings.count == 4)
        #expect(TuningPreset.ukulele[0].strings.count == 4)
    }
}

struct TuningAnalyzerTests {
    @Test func chromaticLocksToA4() {
        let reading = TuningAnalyzer.reading(
            frequency: 440,
            mode: .chromatic,
            strings: InstrumentKind.guitar.defaultPreset.strings,
            lockedStringIndex: nil,
            a4: 440,
            threshold: 5
        )
        #expect(reading.note.pitchClass == .a)
        #expect(reading.note.octave == 4)
        #expect(abs(reading.cents) < 0.01)
        #expect(reading.status(threshold: 5) == .inTune)
    }

    @Test func stringModePicksClosestGuitarString() {
        let strings = InstrumentKind.guitar.defaultPreset.strings
        let e2 = strings[0].frequency(a4: 440)
        let reading = TuningAnalyzer.reading(
            frequency: e2,
            mode: .strings,
            strings: strings,
            lockedStringIndex: nil,
            a4: 440,
            threshold: 5
        )
        #expect(reading.stringIndex == 0)
        #expect(reading.note.pitchClass == .e)
        #expect(reading.status(threshold: 5) == .inTune)
    }

    @Test func sharpFrequencyIsReported() {
        let reading = TuningAnalyzer.reading(
            frequency: 445,
            mode: .chromatic,
            strings: [],
            lockedStringIndex: nil,
            a4: 440,
            threshold: 5
        )
        #expect(reading.cents > 5)
        #expect(reading.status(threshold: 5) == .sharp)
    }
}
