//
//  Movie.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct Movie: CodableEquatable {
    public let adult: Bool
    public let backdropPath: String?
    public let belongsToCollection: MovieCollection?
    public let budget: Int
    public let genres: [Genre]
    public let homepage: String?
    public let id: Int
    public let imdbId: String?
    public let originalLanguage: String
    public let originalTitle: String
    public let overview: String
    public let popularity: Double
    public let posterPath: String?
    public let productionCompanies: [ProductionCompany]
    public let productionCountries: [ProductionCountry]
    public let releaseDate: String
    public let revenue: Int
    public let runtime: Int?
    public let spokenLanguages: [Language]
    public let status: String
    public let tagline: String?
    public let title: String
    public let video: Bool
    public let voteAverage: Double
    public let voteCount: Int

    public let reviews: AppendedReviews?
    public let videos: AppendedVideos?
    public let images: AppendedImages?
}
