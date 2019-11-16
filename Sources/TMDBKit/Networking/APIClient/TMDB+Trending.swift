//
//  TMDB+Trending.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import Foundation

public struct TrendingEndpoints {
    let tmdb: TMDB

    public func trending(_ mediaType: MediaType, withinLast timeWindow: TimeWindow, completion: @escaping TMDBResult<TrendingResponse>) {
        tmdb.fetchObject(ofType: TrendingResponse.self, endpoint: Trending.trending(mediaType: mediaType, timeWindow: timeWindow), completion: completion)
    }
}
