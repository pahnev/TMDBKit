//
//  TVDetails.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/12/2019.
//

import Foundation

public struct TVDetails: CodableEquatable {
    public let backdropPath: String?
    public let createdBy: [CreatedBy]
    public let episodeRunTime: [Int]
    public let firstAirDate: String?
    public let genres: [Genre]
    public let homepage: String
    public let id: Int
    public let inProduction: Bool
    public let languages: [String]
    public let lastAirDate: String
    public let lastEpisodeToAir: LastEpisodeToAir?
    public let name: String
    public let nextEpisodeToAir: LastEpisodeToAir?
    public let networks: [Network]
    public let numberOfEpisodes: Int
    public let numberOfSeasons: Int
    public let originCountry: [String]
    public let originalLanguage: String
    public let originalName: String
    public let overview: String
    public let popularity: Double
    public let posterPath: String?
    public let productionCompanies: [Network]
    public let seasons: [Season]
    public let status: String
    public let type: String
    public let voteAverage: Double
    public let voteCount: Int

    public let reviews: AppendedReviews?
    public let videos: AppendedVideos?
    public let images: AppendedImages?
}

// MARK: - CreatedBy
public struct CreatedBy: CodableEquatable {
    public let id: Int
    public let creditId: String
    public let name: String
    public let gender: Int
    public let profilePath: String

}

// MARK: - LastEpisodeToAir
public struct LastEpisodeToAir: CodableEquatable {
    public let airDate: String
    public let episodeNumber: Int
    public let id: Int
    public let name: String
    public let overview: String
    public let productionCode: String?
    public let seasonNumber: Int
    public let showId: Int
    public let stillPath: String?
    public let voteAverage: Double
    public let voteCount: Int

}

// MARK: - Network
public struct Network: CodableEquatable {
    public let name: String
    public let id: Int
    public let logoPath: String?
    public let originCountry: String
}

public struct RecommendationNetwork: CodableEquatable {
    public struct Logo: CodableEquatable {
        public let path: String
        public let aspectRatio: Double
    }

    public let name: String
    public let id: Int
    public let logo: Logo?
    public let originCountry: String
}


// MARK: - Season
public struct Season: CodableEquatable {
    public let airDate: String?
    public let episodeCount: Int
    public let id: Int
    public let name: String
    public let overview: String
    public let posterPath: String?
    public let seasonNumber: Int
}
