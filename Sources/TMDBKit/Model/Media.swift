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
        // Historical shapes gain the discriminator implied by this typed wrapper.
        // Standalone models still preserve absent mediaType as nil. Normalizing here
        // makes inferred Media values stable through canonical encode/decode.
        if let value = try? container.decode(TVMedia.self) {
            self = .tv(value.withMediaType("tv"))
        } else if let value = try? container.decode(MovieFragment.self) {
            self = .movie(value.withMediaType("movie"))
        } else if let value = try? container.decode(PopularPerson.self) {
            self = .person(value.withMediaType("person"))
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
            try container.encode(tvMedia.withMediaType(nil))
        case .movie(let movieMedia):
            try discriminator.encode("movie", forKey: .mediaType)
            try container.encode(movieMedia.withMediaType(nil))
        case .person(let person):
            try discriminator.encode("person", forKey: .mediaType)
            try container.encode(person.withMediaType(nil))
        case .episode(let episode):
            try discriminator.encode("tv_episode", forKey: .mediaType)
            try container.encode(episode)
        }
    }
}

public struct TVMedia: CodableEquatable {
    public let adult: Bool?
    public let mediaType: String?
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

// A Media wrapper owns its discriminator. These copies avoid encoding both the
// canonical media_type and a synthesized child mediaType alias.
private extension TVMedia {
    func withMediaType(_ type: String?) -> TVMedia {
        return TVMedia(adult: adult, mediaType: type, posterPath: posterPath, popularity: popularity,
                       id: id, backdropPath: backdropPath, voteAverage: voteAverage, overview: overview,
                       firstAirDate: firstAirDate, originCountry: originCountry, genreIds: genreIds,
                       originalLanguage: originalLanguage, voteCount: voteCount, name: name,
                       originalName: originalName)
    }
}

private extension MovieFragment {
    func withMediaType(_ type: String?) -> MovieFragment {
        return MovieFragment(posterPath: posterPath, mediaType: type, adult: adult, overview: overview,
                             releaseDate: releaseDate, genreIds: genreIds, id: id, originalTitle: originalTitle,
                             originalLanguage: originalLanguage, title: title, backdropPath: backdropPath,
                             popularity: popularity, voteCount: voteCount, video: video,
                             voteAverage: voteAverage, rating: rating)
    }
}

private extension PopularPerson {
    func withMediaType(_ type: String?) -> PopularPerson {
        return PopularPerson(originalName: originalName, mediaType: type, popularity: popularity,
                             knownForDepartment: knownForDepartment, gender: gender, id: id,
                             profilePath: profilePath, adult: adult, knownFor: knownFor, name: name)
    }
}
