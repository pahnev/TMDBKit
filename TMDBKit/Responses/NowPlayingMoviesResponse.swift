//
//  NowPlayingMoviesResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct NowPlayingMoviesResponse: CodableEquatable {
    public let dates: TMDBDate
    public let page: Int
    public let results: [MovieFragment]
    public let totalResults: Int
    public let totalPages: Int
}
