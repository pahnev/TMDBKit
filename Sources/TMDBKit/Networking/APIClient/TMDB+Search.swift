//
//  TMDB+Search.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 2.9.2021.
//

import Foundation

public extension TMDB {
    struct SearchEndpoints {
        let tmdb: TMDB

        public func searchForMovies(_ movies: String, page: Int, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            searchForMovies(movies, page: page, language: nil, includeAdult: nil, region: nil,
                            year: nil, primaryReleaseYear: nil, completion: completion)
        }

        /// Search for movies with optional translation, adult-content, region and release-year filters.
        /// Pass nil to omit an option and use the service default.
        public func searchForMovies(_ movies: String, page: Int, language: String?, includeAdult: Bool?, region: String?, year: String?, primaryReleaseYear: String?, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self,
                             endpoint: Search.movies((movies, page), language: language, includeAdult: includeAdult,
                                                     region: region, year: year, primaryReleaseYear: primaryReleaseYear),
                             completion: completion)
        }
    }
}
