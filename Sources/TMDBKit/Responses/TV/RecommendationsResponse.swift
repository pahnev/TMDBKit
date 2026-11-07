//
//  RecommendationsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct RecommendationsResponse: CodableEquatable {
    public struct Result: CodableEquatable {
        public let backdropPath: String
        public let firstAirDate: String
        public let genreIds: [Int]
        public let id: Int
        public let name: String
        public let originCountry: [String]
        public let originalLanguage: String
        public let originalName: String
        public let overview: String
        public let posterPath: String
        public let voteAverage: Double
        public let voteCount: Int
        public let networks: [RecommendationNetwork]
        public let popularity: Double
        public let adult: Bool?
        public let mediaType: String?

        private enum CodingKeys: String, CodingKey {
            case backdropPath, firstAirDate, genreIds, id, name, originCountry, originalLanguage, originalName, overview, posterPath, voteAverage, voteCount, networks, popularity, adult, mediaType
        }

        private enum WireKeys: String, CodingKey {
            case backdropPath = "backdrop_path"
            case firstAirDate = "first_air_date"
            case genreIds = "genre_ids"
            case id
            case name
            case originCountry = "origin_country"
            case originalLanguage = "original_language"
            case originalName = "original_name"
            case overview
            case posterPath = "poster_path"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case networks
            case popularity
            case adult
            case mediaType = "media_type"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            backdropPath = try container.decode(String.self, forKey: .backdropPath)
            firstAirDate = try container.decode(String.self, forKey: .firstAirDate)
            genreIds = try container.decode([Int].self, forKey: .genreIds)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            originCountry = try container.decode([String].self, forKey: .originCountry)
            originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
            originalName = try container.decode(String.self, forKey: .originalName)
            overview = try container.decode(String.self, forKey: .overview)
            posterPath = try container.decode(String.self, forKey: .posterPath)
            voteAverage = try container.decode(Double.self, forKey: .voteAverage)
            voteCount = try container.decode(Int.self, forKey: .voteCount)
            networks = container.contains(.networks) ? try container.decode([RecommendationNetwork].self, forKey: .networks) : []
            popularity = try container.decode(Double.self, forKey: .popularity)
            adult = try container.decodeIfPresent(Bool.self, forKey: .adult)
            mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: WireKeys.self)
            try container.encode(backdropPath, forKey: .backdropPath)
            try container.encode(firstAirDate, forKey: .firstAirDate)
            try container.encode(genreIds, forKey: .genreIds)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(originCountry, forKey: .originCountry)
            try container.encode(originalLanguage, forKey: .originalLanguage)
            try container.encode(originalName, forKey: .originalName)
            try container.encode(overview, forKey: .overview)
            try container.encode(posterPath, forKey: .posterPath)
            try container.encode(voteAverage, forKey: .voteAverage)
            try container.encode(voteCount, forKey: .voteCount)
            try container.encode(networks, forKey: .networks)
            try container.encode(popularity, forKey: .popularity)
            try container.encodeIfPresent(adult, forKey: .adult)
            try container.encodeIfPresent(mediaType, forKey: .mediaType)
        }
    }

    public let page: Int
    public let results: [Result]
    public let totalPages: Int
    public let totalResults: Int
    private enum WireKeys: String, CodingKey {
        case page, results, totalPages = "total_pages", totalResults = "total_results"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WireKeys.self)
        try container.encode(page, forKey: .page)
        try container.encode(results, forKey: .results)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(totalResults, forKey: .totalResults)
    }
}

public struct AppendedRecommendations: CodableEquatable {
    public let page: Int
    public let results: [MovieFragment]
    public let totalPages: Int
    public let totalResults: Int
}
