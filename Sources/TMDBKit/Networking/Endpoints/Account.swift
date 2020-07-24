//
//  Account.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct FavoriteMedia: CodableEquatable {
    public enum MediaType: String, CodableEquatable {
        case tv, movie
    }

    public init(mediaType: MediaType, mediaId: Int, favorite: Bool) {
        self.mediaType = mediaType
        self.mediaId = mediaId
        self.favorite = favorite
    }

    public let mediaType: MediaType
    public let mediaId: Int
    public let favorite: Bool
}

struct SortedPagination {
    enum SortDirection {
        case ascending, descending
    }
    enum Sort {
        case createdAt(SortDirection)
    }
    let sortBy: Sort?
    let page: PageNumber?
}

enum Account: Endpoint {
    case details
    case createdLists(accountId: Int?, pagination: SortedPagination)
    case favoriteMovies(accountId: Int?, pagination: SortedPagination)
    case favoriteTVShows(accountId: Int?, pagination: SortedPagination)
    case markFavorite(accountId: Int?, media: FavoriteMedia)
    case ratedMovies(accountId: Int?, pagination: SortedPagination)
    case ratedTVShows(accountId: Int?, pagination: SortedPagination)
    case ratedTVEpisodes(accountId: Int?, pagination: SortedPagination)
    case movieWatchlist(accountId: Int?, pagination: SortedPagination)
    case tvShowWatchlist(accountId: Int?, pagination: SortedPagination)
    case addToWatchlist(accountId: Int?, media: FavoriteMedia)

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
        case .markFavorite(_, let media),
             .addToWatchlist(_,let media):
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
        case .createdLists(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("lists")
                .appendingSortedPagination(pagination)
        case .favoriteMovies(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite/movies")
                .appendingSortedPagination(pagination)
        case .favoriteTVShows(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite/tv")
                .appendingSortedPagination(pagination)
        case .markFavorite(let accountId, _):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("favorite")
        case .ratedMovies(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/movies")
                .appendingSortedPagination(pagination)
        case .ratedTVShows(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/tv")
                .appendingSortedPagination(pagination)
        case .ratedTVEpisodes(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("rated/tv/episodes")
                .appendingSortedPagination(pagination)
        case .movieWatchlist(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist/movies")
                .appendingSortedPagination(pagination)
        case .tvShowWatchlist(let accountId, pagination: let pagination):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist/tv")
                .appendingSortedPagination(pagination)
        case .addToWatchlist(let accountId, _):
            return account
                .appendingAccountId(accountId)
                .appendingPathComponent("watchlist")
        }
    }


}
