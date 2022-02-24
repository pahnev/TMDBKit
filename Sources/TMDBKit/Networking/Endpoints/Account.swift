//
//  Account.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct ListableMedia {
    public enum MediaType: String, CodableEquatable {
        case tv, movie
    }

    public init(type: MediaType, id: Int) {
        self.type = type
        self.id = id
    }

    public let type: MediaType
    public let id: Int
}

struct FavoriteMedia: CodableEquatable {
    let mediaType: ListableMedia.MediaType
    let mediaId: Int
    let favorite: Bool
}

struct WatchlistMedia: CodableEquatable {
    let mediaType: ListableMedia.MediaType
    let mediaId: Int
    let watchlist: Bool
}

public enum SortDirection {
    case ascending, descending
}

public enum Sort {
    case createdAt(SortDirection)
}

struct SortedPagination {
    let sortBy: Sort?
    let page: PageNumber?
}

enum Account: Endpoint {
    case details
    case createdLists(accountId: Int?, pagination: SortedPagination, language: String?)
    case favoriteMovies(accountId: Int?, pagination: SortedPagination, language: String?)
    case favoriteTVShows(accountId: Int?, pagination: SortedPagination, language: String?)
    case ratedMovies(accountId: Int?, pagination: SortedPagination, language: String?)
    case ratedTVShows(accountId: Int?, pagination: SortedPagination, language: String?)
    case ratedTVEpisodes(accountId: Int?, pagination: SortedPagination, language: String?)
    case movieWatchlist(accountId: Int?, pagination: SortedPagination, language: String?)
    case tvShowWatchlist(accountId: Int?, pagination: SortedPagination, language: String?)
    case markFavorite(accountId: Int?, media: FavoriteMedia)
    case addToWatchlist(accountId: Int?, media: WatchlistMedia)

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .createdLists,
             .favoriteMovies,
             .favoriteTVShows,
             .ratedMovies,
             .ratedTVShows,
             .ratedTVEpisodes,
             .movieWatchlist,
             .tvShowWatchlist:
            return .GET
        case .markFavorite,
             .addToWatchlist:
            return .POST
        }
    }

    var httpBody: Data? {
        switch self {
        case .details,
             .createdLists,
             .favoriteMovies,
             .favoriteTVShows,
             .ratedMovies,
             .ratedTVShows,
             .ratedTVEpisodes,
             .movieWatchlist,
             .tvShowWatchlist:
            return nil
        case .markFavorite(_, let media):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try! encoder.encode(media)
        case .addToWatchlist(_, let media):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try! encoder.encode(media)
        }
    }

    var requestHeaders: [String: String] {
        switch self {
        case .details,
             .createdLists,
             .favoriteMovies,
             .favoriteTVShows,
             .ratedMovies,
             .ratedTVShows,
             .ratedTVEpisodes,
             .movieWatchlist,
             .tvShowWatchlist:
            return [:]
        case .markFavorite,
             .addToWatchlist:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        let account = baseURL.appendingPathComponent("account")

        switch self {
        case .details:
            return account
        case .createdLists(let accountId, let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("lists")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .favoriteMovies(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite/movies")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .favoriteTVShows(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite/tv")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .ratedMovies(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/movies")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .ratedTVShows(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/tv")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .ratedTVEpisodes(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/tv/episodes")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .movieWatchlist(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist/movies")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .tvShowWatchlist(let accountId, pagination: let pagination, let language):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist/tv")
                .appendingSortedPagination(pagination)
                .appendingLanguage(language)
        case .markFavorite(let accountId, _):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite")
        case .addToWatchlist(let accountId, _):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist")
        }
    }
}
