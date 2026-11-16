import Foundation

// MARK: - Tempo (Model)
// BPM clamped to 30...300. beatInterval = 60/bpm.
// fromTapIntervals averages gaps; used by MetronomeModelView.tap().

struct Tempo: Equatable, Sendable {
    static let minimum = 30
    static let maximum = 300
    static let `default` = 120

    var bpm: Int

    init(bpm: Int) {
        self.bpm = Self.clamped(bpm)
    }

    var beatInterval: TimeInterval {
        60.0 / Double(bpm)
    }

    mutating func increment() {
        bpm = Self.clamped(bpm + 1)
    }

    mutating func decrement() {
        bpm = Self.clamped(bpm - 1)
    }

    mutating func set(_ value: Int) {
        bpm = Self.clamped(value)
    }

    static func clamped(_ value: Int) -> Int {
        min(maximum, max(minimum, value))
    }

    static func fromTapIntervals(_ intervals: [TimeInterval]) -> Tempo? {
        guard !intervals.isEmpty else { return nil }
        let average = intervals.reduce(0, +) / Double(intervals.count)
        guard average > 0 else { return nil }
        return Tempo(bpm: Int((60.0 / average).rounded()))
    }
}
