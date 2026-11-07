//
//  WatchProvider.swift
//
//
//  Created by Pahnev, Kirill on 7.12.2021.
//

import Foundation

public struct WatchProviderResponse: CodableEquatable {
    public let id: Int
    public let results: Results?
}

public struct WatchProvider: CodableEquatable {
    public let displayPriority: Int
    public let logoPath: String
    public let providerId: Int
    public let providerName: String

    private enum WireKeys: String, CodingKey {
        case displayPriority = "display_priority", logoPath = "logo_path"
        case providerId = "provider_id", providerName = "provider_name"
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WireKeys.self)
        try container.encode(displayPriority, forKey: .displayPriority)
        try container.encode(logoPath, forKey: .logoPath)
        try container.encode(providerId, forKey: .providerId)
        try container.encode(providerName, forKey: .providerName)
    }
}

public struct ProviderResult: CodableEquatable {
    public let link: String?
    public let buy: [WatchProvider]?
    public let rent: [WatchProvider]?
    public let flatrate: [WatchProvider]?
    public let ads: [WatchProvider]?
    public let free: [WatchProvider]?
}

public struct Results: CodableEquatable {
    public let regions: [String: ProviderResult]

    public subscript(region: String) -> ProviderResult? { regions[region] }

    // Decode a dictionary rather than CodingKeys so key strategies cannot rewrite
    // arbitrary wire region keys (including keys unknown to this SDK version).
    public init(from decoder: Decoder) throws {
        regions = try decoder.singleValueContainer().decode([String: ProviderResult].self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(regions)
    }

    public var ar: ProviderResult? { regions["AR"] }
    public var at: ProviderResult? { regions["AT"] }
    public var au: ProviderResult? { regions["AU"] }
    public var be: ProviderResult? { regions["BE"] }
    public var bg: ProviderResult? { regions["BG"] }
    public var bo: ProviderResult? { regions["BO"] }
    public var br: ProviderResult? { regions["BR"] }
    public var ca: ProviderResult? { regions["CA"] }
    public var ch: ProviderResult? { regions["CH"] }
    public var cl: ProviderResult? { regions["CL"] }
    public var co: ProviderResult? { regions["CO"] }
    public var cr: ProviderResult? { regions["CR"] }
    public var cz: ProviderResult? { regions["CZ"] }
    public var de: ProviderResult? { regions["DE"] }
    public var dk: ProviderResult? { regions["DK"] }
    public var ec: ProviderResult? { regions["EC"] }
    public var ee: ProviderResult? { regions["EE"] }
    public var es: ProviderResult? { regions["ES"] }
    public var fi: ProviderResult? { regions["FI"] }
    public var fr: ProviderResult? { regions["FR"] }
    public var gb: ProviderResult? { regions["GB"] }
    public var gr: ProviderResult? { regions["GR"] }
    public var gt: ProviderResult? { regions["GT"] }
    public var hk: ProviderResult? { regions["HK"] }
    public var hn: ProviderResult? { regions["HN"] }
    public var hu: ProviderResult? { regions["HU"] }
    public var id: ProviderResult? { regions["ID"] }
    public var ie: ProviderResult? { regions["IE"] }
    public var iN: ProviderResult? { regions["IN"] }
    public var it: ProviderResult? { regions["IT"] }
    public var jp: ProviderResult? { regions["JP"] }
    public var kr: ProviderResult? { regions["KR"] }
    public var lt: ProviderResult? { regions["LT"] }
    public var lv: ProviderResult? { regions["LV"] }
    public var mx: ProviderResult? { regions["MX"] }
    public var my: ProviderResult? { regions["MY"] }
    public var nl: ProviderResult? { regions["NL"] }
    public var no: ProviderResult? { regions["NO"] }
    public var nz: ProviderResult? { regions["NZ"] }
    public var pe: ProviderResult? { regions["PE"] }
    public var ph: ProviderResult? { regions["PH"] }
    public var pl: ProviderResult? { regions["PL"] }
    public var pt: ProviderResult? { regions["PT"] }
    public var py: ProviderResult? { regions["PY"] }
    public var ro: ProviderResult? { regions["RO"] }
    public var ru: ProviderResult? { regions["RU"] }
    public var se: ProviderResult? { regions["SE"] }
    public var sg: ProviderResult? { regions["SG"] }
    public var th: ProviderResult? { regions["TH"] }
    public var tr: ProviderResult? { regions["TR"] }
    public var us: ProviderResult? { regions["US"] }
    public var ve: ProviderResult? { regions["VE"] }
    public var za: ProviderResult? { regions["ZA"] }
}
