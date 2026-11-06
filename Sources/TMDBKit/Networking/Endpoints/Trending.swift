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
    case trending(mediaType: MediaType, timeWindow: TimeWindow, language: String? = nil)

    var url: URL {
        switch self {
        case .trending(let mediaType, let timeWindow, let language):
            return baseURL.appendingPathComponent("trending/\(mediaType.rawValue)/\(timeWindow.rawValue)")
                .appendingLanguage(language)
        }
    }
}
