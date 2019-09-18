//
//  MovieCollection.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct MovieCollection: CodableEquatable {
    public let id: Int
    public let name: String
    public let posterPath: String
    public let backdropPath: String
}
