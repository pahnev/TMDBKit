import Foundation

/// Lossless JSON change payload. Object keys retain their original wire spelling.
public indirect enum ChangeValue: CodableEquatable {
    case string(String)
    case integer(Int)
    case number(Double)
    case bool(Bool)
    case object([String: ChangeValue])
    case array([ChangeValue])
    case null

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if value.decodeNil() { self = .null; return }
        // Test integers before floating point to preserve integral identifiers exactly.
        do { self = .integer(try value.decode(Int.self)); return } catch DecodingError.typeMismatch {} catch {}
        do { self = .number(try value.decode(Double.self)); return } catch DecodingError.typeMismatch {}
        do { self = .bool(try value.decode(Bool.self)); return } catch DecodingError.typeMismatch {}
        do { self = .string(try value.decode(String.self)); return } catch DecodingError.typeMismatch {}
        do { self = .object(try value.decode([String: ChangeValue].self)); return } catch DecodingError.typeMismatch {}
        self = .array(try value.decode([ChangeValue].self))
    }

    public func encode(to encoder: Encoder) throws {
        var value = encoder.singleValueContainer()
        switch self {
        case .string(let payload): try value.encode(payload)
        case .integer(let payload): try value.encode(payload)
        case .number(let payload): try value.encode(payload)
        case .bool(let payload): try value.encode(payload)
        case .object(let payload): try value.encode(payload)
        case .array(let payload): try value.encode(payload)
        case .null: try value.encodeNil()
        }
    }
}
