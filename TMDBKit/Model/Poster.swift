//
//  Poster.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Image: CodableEquatable {
    public let aspectRatio: Double
    public let filePath: String
    public let height: Int
    public let iso6391: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let width: Int
}
