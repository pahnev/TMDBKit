import Foundation

public struct Change: CodableEquatable {
    public struct Item: CodableEquatable {
        public let id: String
        public let action: String
        public let time: String
        public let iso6391Data: String?
        public let iso31661: String?
        public let valueData: ChangeValue?
        public let originalValueData: ChangeValue?

        /// Empty strings are compatibility sentinels, not returned API values.
        @available(*, deprecated, message: "Use iso6391Data for optional locale data")
        public var iso6391: String { iso6391Data ?? "" }
        @available(*, deprecated, message: "Use valueData for typed change payloads")
        public var value: String { if case .string(let text)? = valueData { return text }; return "" }
        @available(*, deprecated, message: "Use originalValueData for typed change payloads")
        public var originalValue: String { if case .string(let text)? = originalValueData { return text }; return "" }

        private enum CodingKeys: String, CodingKey {
            case id, action, time, iso6391, iso31661, value, originalValue
        }
        private enum WireKeys: String, CodingKey {
            case id, action, time
            case iso6391 = "iso_639_1", iso31661 = "iso_3166_1"
            case value, originalValue = "original_value"
        }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            action = try container.decode(String.self, forKey: .action)
            time = try container.decode(String.self, forKey: .time)
            iso6391Data = try container.decodeIfPresent(String.self, forKey: .iso6391)
            iso31661 = try container.decodeIfPresent(String.self, forKey: .iso31661)
            valueData = container.contains(.value) ? try container.decode(ChangeValue.self, forKey: .value) : nil
            originalValueData = container.contains(.originalValue) ? try container.decode(ChangeValue.self, forKey: .originalValue) : nil
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: WireKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(action, forKey: .action)
            try container.encode(time, forKey: .time)
            try container.encodeIfPresent(iso6391Data, forKey: .iso6391)
            try container.encodeIfPresent(iso31661, forKey: .iso31661)
            try container.encodeIfPresent(valueData, forKey: .value)
            try container.encodeIfPresent(originalValueData, forKey: .originalValue)
        }
    }
    public let key: String
    public let items: [Item]
}

public struct TVChange: CodableEquatable {
    public struct Item: CodableEquatable {
        public struct Value: CodableEquatable {
            public struct Poster: CodableEquatable {
                public let filePath: String
                public let iso6391: String?
            }
            public let rawValue: ChangeValue
            public var posterValue: Poster? {
                guard case .object(let object) = rawValue,
                      case .object(let poster)? = object["poster"],
                      case .string(let path)? = poster["file_path"] else { return nil }
                let locale: String?
                if case .string(let text)? = poster["iso_639_1"] { locale = text } else { locale = nil }
                return Poster(filePath: path, iso6391: locale)
            }
            /// Returns an empty-path sentinel if this payload is not a poster.
            @available(*, deprecated, message: "Use posterValue or rawValue")
            public var poster: Poster { posterValue ?? Poster(filePath: "", iso6391: nil) }
            public init(rawValue: ChangeValue) { self.rawValue = rawValue }
            public init(from decoder: Decoder) throws { rawValue = try ChangeValue(from: decoder) }
            public func encode(to encoder: Encoder) throws { try rawValue.encode(to: encoder) }
        }
        public let id: String
        public let action: String
        public let time: String
        public let iso6391Data: String?
        public let iso31661Data: String?
        public let valueData: ChangeValue?
        public let originalValueData: ChangeValue?

        @available(*, deprecated, message: "Use iso6391Data")
        public var iso6391: String { iso6391Data ?? "" }
        @available(*, deprecated, message: "Use iso31661Data")
        public var iso31661: String { iso31661Data ?? "" }
        /// Missing payloads project to null for source compatibility only.
        @available(*, deprecated, message: "Use valueData to distinguish missing and null")
        public var value: Value { Value(rawValue: valueData ?? .null) }
        @available(*, deprecated, message: "Use originalValueData to distinguish missing and null")
        public var originalValue: Value { Value(rawValue: originalValueData ?? .null) }

        private enum CodingKeys: String, CodingKey {
            case id, action, time, iso6391, iso31661, value, originalValue
        }
        private enum WireKeys: String, CodingKey {
            case id, action, time
            case iso6391 = "iso_639_1", iso31661 = "iso_3166_1"
            case value, originalValue = "original_value"
        }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            action = try container.decode(String.self, forKey: .action)
            time = try container.decode(String.self, forKey: .time)
            iso6391Data = try container.decodeIfPresent(String.self, forKey: .iso6391)
            iso31661Data = try container.decodeIfPresent(String.self, forKey: .iso31661)
            valueData = container.contains(.value) ? try container.decode(ChangeValue.self, forKey: .value) : nil
            originalValueData = container.contains(.originalValue) ? try container.decode(ChangeValue.self, forKey: .originalValue) : nil
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: WireKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(action, forKey: .action)
            try container.encode(time, forKey: .time)
            try container.encodeIfPresent(iso6391Data, forKey: .iso6391)
            try container.encodeIfPresent(iso31661Data, forKey: .iso31661)
            try container.encodeIfPresent(valueData, forKey: .value)
            try container.encodeIfPresent(originalValueData, forKey: .originalValue)
        }
    }
    public let key: String
    public let items: [Item]
}
