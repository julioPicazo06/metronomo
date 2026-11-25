import Foundation

// MARK: - InstrumentKind (Model)
// Guitar / bass4 / bass5 / violin / ukulele. Preset tables live in TuningPresets.swift.

enum InstrumentKind: String, CaseIterable, Sendable, Equatable {
    case guitar
    case bass4
    case bass5
    case violin
    case ukulele

    var title: String {
        TunerCopy.Instrument.title(for: self)
    }

    var presets: [TuningPreset] {
        switch self {
        case .guitar: TuningPreset.guitar
        case .bass4: TuningPreset.bass4
        case .bass5: TuningPreset.bass5
        case .violin: TuningPreset.violin
        case .ukulele: TuningPreset.ukulele
        }
    }

    var defaultPreset: TuningPreset {
        presets[0]
    }

    /// Maps legacy persisted values (e.g. `"bass"`) onto the current cases.
    static func persisted(from raw: String) -> InstrumentKind? {
        if raw == "bass" { return .bass4 }
        return InstrumentKind(rawValue: raw)
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

// MARK: - TunerMode (Model)
// strings = snap to nearest open string. chromatic = nearest 12-TET note.

enum TunerMode: String, CaseIterable, Sendable, Equatable {
    case strings
    case chromatic

    var title: String {
        TunerCopy.Mode.title(for: self)
    }
}
