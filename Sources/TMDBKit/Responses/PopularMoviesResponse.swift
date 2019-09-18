//
//  PopularMoviesResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct PopularMoviesResponse: CodableEquatable {
    public let page: Int
    public let results: [MovieFragment]
    public let totalResults: Int
    public let totalPages: Int
}
