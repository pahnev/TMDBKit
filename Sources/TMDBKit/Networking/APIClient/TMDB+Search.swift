//
//  Search.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 2.9.2021.
//

import Foundation

public extension TMDB {
    struct SearchEndpoints {
        let tmdb: TMDB

        public func searchForMovies(_ movies: String, page: Int, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Search.movies((movies, page)), completion: completion)
        }
    }
}
