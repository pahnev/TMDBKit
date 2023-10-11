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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        watchlist = try container.decode(Bool.self, forKey: .watchlist)
        rated = try? container.decode(Rating.self, forKey: .rated)
    }
}
