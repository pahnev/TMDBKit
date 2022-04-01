//
//  TMDB+Discover.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 24.2.2022.
//  Copyright © 2022 Pahnev. All rights reserved.
//

import Foundation

public enum DiscoverSort {
    case popularity(SortDirection)
    case releaseDate(SortDirection)
    case revenue(SortDirection)
    case primaryReleaseDate(SortDirection)
    case originalTitle(SortDirection)
    case voteAverage(SortDirection)
    case voteCount(SortDirection)
}

public enum DiscoveryFilter {
    /// A filter to limit the results to a specific year (looking at all release dates).
    case year(Int)

    /// Specify a ISO 3166-1 code to filter release dates. Must be uppercase.
    case region(String)

    var queryItem: URLQueryItem? {
        switch self {
        case .year(let year):
            return URLQueryItem(name: "year", value: String(year))
        case .region(let region):
            return URLQueryItem(name: "region", value: region)
        }
    }

}
extension URLQueryItem {
    init?(valueWithMatchingName value: String?) {
        guard let value = value else { return nil }
        self = URLQueryItem(name: value, value: value)
    }
}

public extension TMDB {
    struct DiscoverEndpoints {
        let tmdb: TMDB

        public func movies(in language: String? = nil,
                           sortBy: DiscoverSort? = nil,
                           pageNumber: PageNumber = 1,
                           filteringBy: [DiscoveryFilter]? = nil,
                           completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self,
                             endpoint: Discover.movies(language: language, sort: sortBy, page: pageNumber, filters: filteringBy),
                             completion: completion)

        }

        public func tvShows(in language: String? = nil,
                            sortBy: DiscoverSort? = nil,
                            pageNumber: PageNumber = 1,
                            filteringBy: [DiscoveryFilter]? = nil,
                            completion: @escaping TMDBResult<SimilarShowsResponse>) {

            tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: Discover.tvShows, completion: completion)
        }
    }
}

enum Discover: Endpoint {
    case movies(language: String?, sort: DiscoverSort?, page: PageNumber?, filters: [DiscoveryFilter]?)
    case tvShows

    var url: URL {
        let discover = baseURL.appendingPathComponent("discover")
        switch self {
        case .movies(let language, let sort, let page, let filters):
            let f = filters?.flatMap { $0.queryItem}
            return discover.appendingPathComponent("movie")
                .appendingQueryItems(f)
        case .tvShows:
            return discover.appendingPathComponent("tv")
        }
    }
}
