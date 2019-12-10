//
//  TaggedImageResponse.swift
//  Nimble
//
//  Created by Pahnev, Kirill on 15/11/2019.
//

import Foundation

public struct Media: CodableEquatable {
    public let posterPath: String
    public let overview: String
    public let genreIDS: [Int]?
    public let id: Int
    // Can be missing in popular person response
    public let popularity: Double?
    public let originalLanguage: String
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int

    // MediaType Movie only
    public let adult: Bool?
    public let originalName: String?
    public let releaseDate: String?
    public let title: String?
    public let video: Bool?

    // MediaType TV only
    public let originalTitle: String?
}

public struct TaggedImageResponse: CodableEquatable {
    public struct Result: CodableEquatable {
        public enum MediaType: String, CodableEquatable {
            case movie
            case tv
        }

        public let iso6391: String?
        public let voteCount: Int
        public let mediaType: MediaType
        public let filePath: String
        public let aspectRatio: Double
        public let media: Media
        public let height: Int
        public let voteAverage: Double
        public let width: Int
    }

    public let id: Int
    public let page: Int
    public let totalResults: Int
    public let results: [Result]
    public let totalPages: Int
}
