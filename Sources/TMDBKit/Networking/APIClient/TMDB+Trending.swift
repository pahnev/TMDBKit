//
//  TMDB+Trending.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import Foundation

public struct TrendingEndpoints {
    let tmdb: TMDB

    /// Get the daily or weekly trending items. The daily trending list tracks items over the period of a day while items have a 24 hour half life. The weekly list tracks items over a 7 day period, with a 7 day half life.
    ///
    /// - Parameters:
    ///   - mediaType: The type of media to include. `.all` will include all movies, TV shows and people in the results as a global trending list
    ///   - timeWindow: The time period of the results to be returned.
    ///   - completion: The closure called on completion with `TrendingResponse` or `TMDBError`.
    public func trending(_ mediaType: MediaType, withinLast timeWindow: TimeWindow, completion: @escaping TMDBResult<TrendingResponse>) {
        tmdb.fetchObject(ofType: TrendingResponse.self, endpoint: Trending.trending(mediaType: mediaType, timeWindow: timeWindow), completion: completion)
    }
}
