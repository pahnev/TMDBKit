//
//  Media.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 15/11/2019.
//

import Foundation

public enum Media: CodableEquatable {
    case tv(TVMedia)
    case movie(MovieFragment)
    case person(PopularPerson)
}

extension Media {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let tvMedia = try? container.decode(TVMedia.self) {
            self = .tv(tvMedia)
            return
        } else if let movieMedia = try? container.decode(MovieFragment.self) {
            self = .movie(movieMedia)
            return
        } else if let person = try? container.decode(PopularPerson.self) {
            self = .person(person)
            return
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                debugDescription: "Media type not supported."))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .tv(let tvMedia):
            try container.encode(tvMedia)
        case .movie(let movieMedia):
            try container.encode(movieMedia)
        case .person(let person):
            try container.encode(person)
        }
    }
}

public struct TVMedia: CodableEquatable {
    public let posterPath: String?
    /// Missing from popular people response.
    public let popularity: Double?
    public let id: Int
    public let backdropPath: String?
    public let voteAverage: Double
    public let overview: String
    public let firstAirDate: String
    public let originCountry: [String]
    public let genreIds: [Int]
    public let originalLanguage: String
    public let voteCount: Int
    public let name: String
    public let originalName: String
}
