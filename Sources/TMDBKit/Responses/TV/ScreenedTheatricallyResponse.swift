//
//  ScreenedTheatricallyResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct ScreenedTheatricallyResponse: CodableEquatable {
    public struct Result: CodableEquatable {
        public let id: Int
        public let episodeNumber: Int
        public let seasonNumber: Int
    }
    public let id: Int
    public let results: [Result]
}
