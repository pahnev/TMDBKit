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
    }

    public let page: Int
    public let results: [Result]
    public let totalPages: Int
    public let totalResults: Int
}
