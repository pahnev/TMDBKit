//
//  PersonMovieCreditsResponse.swift
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
}

public struct AppendedPersonCredits: CodableEquatable {
    public let cast: [CreditsCast]
    public let crew: [CreditsCast]
}
