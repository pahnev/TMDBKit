//
//  SimilarShowsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct SimilarShowsResponse: CodableEquatable {
    public let page: Int
    public let results: [TVShowFragment]
    public let totalPages: Int
    public let totalResults: Int
}

public struct TVShowFragment: CodableEquatable {
    public let originalName: String
    public let id: Int
    public let name: String
    public let voteCount: Int
    public let voteAverage: Double
    public let firstAirDate: String
    public let posterPath: String
    public let genreIds: [Int]
    public let originalLanguage: String
    public let backdropPath: String
    public let overview: String
    public let originCountry: [String]
    public let popularity: Double
}
