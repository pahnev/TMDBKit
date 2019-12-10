//
//  ReviewsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct ReviewsResponse: CodableEquatable {
    public let id: Int
    public let page: Int
    public let results: [Review]
    public let totalPages: Int
    public let totalResults: Int
}

public struct AppendedReviews: CodableEquatable {
    public let page: Int
    public let results: [Review]
    public let totalPages: Int
    public let totalResults: Int
}
