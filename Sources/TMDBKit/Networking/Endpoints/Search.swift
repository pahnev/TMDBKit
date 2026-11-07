//
//  Search.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18/09/2019.
//

import Foundation

enum Search: Endpoint {
    typealias SearchParam = (query: String, page: Int)
    case companies(SearchParam)
    case collections(SearchParam)
    case keywords(SearchParam)
    case movies(SearchParam, language: String? = nil, includeAdult: Bool? = nil, region: String? = nil, year: String? = nil, primaryReleaseYear: String? = nil)
    case multiSearch(SearchParam)
    case people(SearchParam)
    case tvShows(SearchParam)

    var url: URL {
        let search = baseURL.appendingPathComponent("search")
        switch self {
        case .companies((let query, let page)):
            return search.appendingPathComponent("company")
                .appendingSearchQuery(query)
                .appendingPage(page)
        case .collections((let query, let page)):
            return search.appendingPathComponent("collection")
                .appendingSearchQuery(query)
                .appendingPage(page)
        case .keywords((let query, let page)):
            return search.appendingPathComponent("keyword")
                .appendingSearchQuery(query)
                .appendingPage(page)
        case .movies((let query, let page), let language, let includeAdult, let region, let year, let primaryReleaseYear):
            let options = [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "include_adult", value: includeAdult.map { String($0) }),
                URLQueryItem(name: "region", value: region),
                URLQueryItem(name: "year", value: year),
                URLQueryItem(name: "primary_release_year", value: primaryReleaseYear)
            ].filter { $0.value != nil }
            return search.appendingPathComponent("movie")
                .appendingSearchQuery(query)
                .appendingPage(page)
                .appendingQueryItems(options)
        case .multiSearch((let query, let page)):
            return search.appendingPathComponent("multi")
                .appendingSearchQuery(query)
                .appendingPage(page)
        case .people((let query, let page)):
            return search.appendingPathComponent("person")
                .appendingSearchQuery(query)
                .appendingPage(page)
        case .tvShows((let query, let page)):
            return search.appendingPathComponent("tv")
                .appendingSearchQuery(query)
                .appendingPage(page)
        }
    }
}
