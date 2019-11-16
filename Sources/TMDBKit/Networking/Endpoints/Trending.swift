//
//  Trending.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import Foundation

public enum MediaType: String {
    case all, movie, tv, person
}

public enum TimeWindow: String {
    case day, week
}

enum Trending: Endpoint {
    case trending(mediaType: MediaType, timeWindow: TimeWindow)

    var url: URL {
        switch self {
        case .trending(let params):
            return baseURL.appendingPathComponent("trending/\(params.mediaType.rawValue)/\(params.timeWindow.rawValue)")
        }
    }
}
