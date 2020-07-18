//
//  EpisodeListResponse.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct EpisodeListResponse: CodableEquatable {
    public let page: Int
    public let results: [LastEpisodeToAir]
    public let totalPages: Int
    public let totalResults: Int
}
