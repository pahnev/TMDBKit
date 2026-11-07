//
//  AccountState.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 7.12.2021.
//  Copyright © 2021 Pahnev. All rights reserved.
//

import Foundation

public struct AccountState: CodableEquatable {
    public struct Rating: CodableEquatable {
        public let value: Double
    }

    public let id: Int
    public let favorite: Bool
    public let rated: Rating?
    public let watchlist: Bool

    private enum CodingKeys: String, CodingKey { case id, favorite, rated, watchlist }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(watchlist, forKey: .watchlist)
        if let rated = rated {
            try container.encode(rated, forKey: .rated)
        } else {
            try container.encode(false, forKey: .rated)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        watchlist = try container.decode(Bool.self, forKey: .watchlist)
        if let flag = try? container.decode(Bool.self, forKey: .rated) {
            guard !flag else {
                throw DecodingError.dataCorruptedError(forKey: .rated, in: container, debugDescription: "rated must be false or a numeric rating object")
            }
            rated = nil
        } else {
            rated = try container.decode(Rating.self, forKey: .rated)
        }
    }
}
