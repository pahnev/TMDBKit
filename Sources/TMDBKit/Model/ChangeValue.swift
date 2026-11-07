import Foundation

/// JSON change payload preserving integral identifiers and original object-key spelling.
/// Integral tokens decode as `integer` before `number`. A manually constructed
/// `number(1.0)` may encode as `1` and canonicalize to `integer(1)` on decoding;
/// exact numeric enum-case preservation is not guaranteed for whole-valued Doubles.
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
        if value.decodeNil() {
            self = .null
            return
        }
        // Test integers before floating point to preserve integral identifiers exactly.
        do { self = try .integer(value.decode(Int.self))
            return
        } catch DecodingError.typeMismatch {} catch {}
        do { self = try .number(value.decode(Double.self))
            return
        } catch DecodingError.typeMismatch {}
        do { self = try .bool(value.decode(Bool.self))
            return
        } catch DecodingError.typeMismatch {}
        do { self = try .string(value.decode(String.self))
            return
        } catch DecodingError.typeMismatch {}
        do { self = try .object(value.decode([String: ChangeValue].self))
            return
        } catch DecodingError.typeMismatch {}
        self = try .array(value.decode([ChangeValue].self))
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
