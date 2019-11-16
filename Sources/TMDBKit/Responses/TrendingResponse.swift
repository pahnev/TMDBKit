//
//  TrendingResponse.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import Foundation

public struct TrendingResponse: CodableEquatable {
    public let page: Int
    public let totalPages: Int
    public let totalResults: Int
    public let results: [Media]
}
