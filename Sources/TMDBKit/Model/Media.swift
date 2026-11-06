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
    /// Tagged episode media; exhaustive switches must handle this case.
    case episode(LastEpisodeToAir)
}

public extension Media {
    private enum DiscriminatorKey: String, CodingKey { case mediaType }
    private enum WireKey: String, CodingKey { case mediaType = "media_type" }

    init(from decoder: Decoder) throws {
        let keyed = try decoder.container(keyedBy: DiscriminatorKey.self)
        let container = try decoder.singleValueContainer()
        if keyed.contains(.mediaType) {
            let type = try keyed.decode(String.self, forKey: .mediaType)
            switch type {
            case "tv": self = .tv(try container.decode(TVMedia.self))
            case "movie": self = .movie(try container.decode(MovieFragment.self))
            case "person": self = .person(try container.decode(PopularPerson.self))
            case "tv_episode": self = .episode(try container.decode(LastEpisodeToAir.self))
            default:
                throw DecodingError.dataCorruptedError(forKey: .mediaType, in: keyed,
                                                       debugDescription: "Unsupported media discriminator: \(type)")
            }
            return
        }
        // Historical responses without media_type retain their shape-based decoding.
        if let tvMedia = try? container.decode(TVMedia.self) {
            self = .tv(tvMedia)
        } else if let movieMedia = try? container.decode(MovieFragment.self) {
            self = .movie(movieMedia)
        } else if let person = try? container.decode(PopularPerson.self) {
            self = .person(person)
        } else if let episode = try? container.decode(LastEpisodeToAir.self) {
            self = .episode(episode)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath,
                                                   debugDescription: "Media type not supported."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var discriminator = encoder.container(keyedBy: WireKey.self)
        var container = encoder.singleValueContainer()
        switch self {
        case .tv(let tvMedia):
            try discriminator.encode("tv", forKey: .mediaType)
            try container.encode(tvMedia)
        case .movie(let movieMedia):
            try discriminator.encode("movie", forKey: .mediaType)
            try container.encode(movieMedia)
        case .person(let person):
            try discriminator.encode("person", forKey: .mediaType)
            try container.encode(person)
        case .episode(let episode):
            try discriminator.encode("tv_episode", forKey: .mediaType)
            try container.encode(episode)
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
