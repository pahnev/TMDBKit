//
//  TaggedImageResponse.swift
//  Nimble
//
//  Created by Pahnev, Kirill on 15/11/2019.
//

import Foundation

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
