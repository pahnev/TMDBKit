//
//  Search.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18/09/2019.
//

import Foundation

enum Search {
    typealias SearchParam = (query: String, page: Int)
    case companies(SearchParam)
    case collections(SearchParam)
    case keywords(SearchParam)
    case movies(SearchParam)
    case multiSearch(SearchParam)
    case people(SearchParam)
    case tvShows(SearchParam)
}
