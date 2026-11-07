//
//  PersonCreditsResponse.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import Foundation

public struct PersonCreditsResponse: CodableEquatable {
    public let cast: [CreditsCast]
    public let crew: [CreditsCast]
    public let id: Int
}

// MARK: - Cast

public struct CreditsCast: CodableEquatable {
    public let character: String?
    public let creditID: String?
    public let posterPath: String?
    public let id: Int
    public let voteCount: Int
    public let backdropPath: String?
    public let genreIDS: [Int]?
    public let originalLanguage: String
    public let popularity: Double
    public let voteAverage: Double
    public let overview: String
    public let department: String?
    public let job: String?

    // Movie Cast
    public let video: Bool?
    public let adult: Bool?
    public let originalTitle: String?
    public let title: String?
    public let releaseDate: String?

    // TV Cast
    public let originalName: String?
    public let name: String?
    public let episodeCount: Int?
    public let firstAirDate: String?
    public let originCountry: [String]?
    public let order: Int?
    public let mediaType: String?
    public var creditId: String? {
        creditID
    }

    public var genreIds: [Int]? {
        genreIDS
    }

    private enum CodingKeys: String, CodingKey {
        case character
        case creditID = "creditId"
        case posterPath
        case id
        case voteCount
        case backdropPath
        case genreIDS = "genreIds"
        case originalLanguage
        case popularity
        case voteAverage
        case overview
        case department
        case job
        case video
        case adult
        case originalTitle
        case title
        case releaseDate
        case originalName
        case name
        case episodeCount
        case firstAirDate
        case originCountry
        case order
        case mediaType
    }

    private enum WireKeys: String, CodingKey {
        case character
        case creditID = "credit_id"
        case posterPath = "poster_path"
        case id
        case voteCount = "vote_count"
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case originalLanguage = "original_language"
        case popularity
        case voteAverage = "vote_average"
        case overview
        case department
        case job
        case video
        case adult
        case originalTitle = "original_title"
        case title
        case releaseDate = "release_date"
        case originalName = "original_name"
        case name
        case episodeCount = "episode_count"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case order
        case mediaType = "media_type"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WireKeys.self)
        try container.encodeIfPresent(character, forKey: .character)
        try container.encodeIfPresent(creditID, forKey: .creditID)
        try container.encodeIfPresent(posterPath, forKey: .posterPath)
        try container.encode(id, forKey: .id)
        try container.encode(voteCount, forKey: .voteCount)
        try container.encodeIfPresent(backdropPath, forKey: .backdropPath)
        try container.encodeIfPresent(genreIDS, forKey: .genreIDS)
        try container.encode(originalLanguage, forKey: .originalLanguage)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(overview, forKey: .overview)
        try container.encodeIfPresent(department, forKey: .department)
        try container.encodeIfPresent(job, forKey: .job)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(adult, forKey: .adult)
        try container.encodeIfPresent(originalTitle, forKey: .originalTitle)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)
        try container.encodeIfPresent(originalName, forKey: .originalName)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(episodeCount, forKey: .episodeCount)
        try container.encodeIfPresent(firstAirDate, forKey: .firstAirDate)
        try container.encodeIfPresent(originCountry, forKey: .originCountry)
        try container.encodeIfPresent(order, forKey: .order)
        try container.encodeIfPresent(mediaType, forKey: .mediaType)
    }
}

public struct AppendedPersonCredits: CodableEquatable {
    public let cast: [CreditsCast]
    public let crew: [CreditsCast]
}
