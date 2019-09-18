//
//  Result.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct MovieFragment: CodableEquatable {
    public let posterPath: String?
    public let adult: Bool
    public let overview: String
    public let releaseDate: String
    public let genreIds: [Int]
    public let id: Int
    public let originalTitle: String
    public let originalLanguage: String
    public let title: String
    public let backdropPath: String?
    public let popularity: Double?
    public let voteCount: Int
    public let video: Bool
    public let voteAverage: Double
}
