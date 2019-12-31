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

    /// Nil unless the appended to the API call.
    public let reviews: AppendedReviews?

    /// Nil unless the appended to the API call.
    public let videos: AppendedVideos?

    /// Nil unless the appended to the API call.
    public let images: AppendedImages?

    /// Nil unless the appended to the API call.
    public let credits: AppendedCredits?

    /// Nil unless the appended to the API call.
    public let recommendations: AppendedRecommendations?

    /// Nil unless the appended to the API call.
    public let similar: PopularMoviesResponse?

    /// Nil unless the appended to the API call.
    public let translations: AppendedTranslations?
}
