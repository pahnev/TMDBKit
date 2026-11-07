//
//  TMDB+Account.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public extension TMDB {
    struct AccountEndpoints {
        let tmdb: TMDB

        /// Legacy current-session lookup using `/account`.
        /// The pinned contract documents only explicit account IDs; this route is
        /// preserved for source compatibility and remains an unverified server convention.
        ///
        /// - Parameter completion: Result of `AccountDetails` or `TMDBError`
        public func details(completion: @escaping TMDBResult<AccountDetails>) {
            tmdb.authenticatedRequestAndParse(Account.details, completion: completion)
        }

        /// Get account details using the documented explicit account-ID route.
        /// Application authentication is required; a configured user session is included when available.
        public func details(for accountId: Int, completion: @escaping TMDBResult<AccountDetails>) {
            tmdb.requestAndParseWithOptionalSession(Account.detailsFor(accountId: accountId), completion: completion)
        }

        /// Get all the lists created by an account. Will include private lists if you are the owner.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose lists to fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: Ignored compatibility argument; created lists do not support a language query.
        ///   - sortBy: Ignored compatibility argument; created lists do not support a sort query.
        ///   - completion: Result of `ListsResponse` or `TMDBError`
        public func createdListsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<ListsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.createdLists(accountId: accountId,
                                                                            pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                            language: language),
                                                  completion: completion)
        }

        /// Get the list of your favorite movies.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose favorite movies fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `HTTPResponseContaining<PopularMoviesResponse>` or `TMDBError`
        public func favoriteMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.favoriteMovies(accountId: accountId,
                                                                              pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                              language: language),
                                                  completion: completion)
        }

        /// Get the list of your favorite TV shows.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose favorite TV shows fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func favoriteTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.favoriteTVShows(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                               language: language),
                                                  completion: completion)
        }

        /// Get a list of all the movies you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated movies fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
        public func ratedMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedMovies(accountId: accountId,
                                                                           pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                           language: language),
                                                  completion: completion)
        }

        /// Get a list of all the TV shows you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated TV shows fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func ratedTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedTVShows(accountId: accountId,
                                                                            pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                            language: language),
                                                  completion: completion)
        }

        /// Get a list of all the TV episodes you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated TV episodes fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `EpisodeListResponse` or `TMDBError`
        public func ratedTVEpisodesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<EpisodeListResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedTVEpisodes(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                               language: language),
                                                  completion: completion)
        }

        /// Get a list of all the movies you have added to your watchlist.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose movie watchlist to fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
        public func movieWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.movieWatchlist(accountId: accountId,
                                                                              pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                              language: language),
                                                  completion: completion)
        }

        /// Get a list of all the TV shows you have added to your watchlist.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose TV show watchlist to fetch. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - sortBy: Sort the results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func tvShowWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.tvShowWatchlist(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: sortBy, page: pageNumber),
                                                                               language: language),
                                                  completion: completion)
        }

        // MARK: - POST

        // This method allows you to mark a movie or TV show as a favorite item.
        //
        // - Parameters:
        //   - isFavorite: Whether the item should be added or removed from favorites list.
        //   - media: The media to be added or removed from favorites list.
        //   - accountId: The `accountId`, of the user. Nil preserves the legacy ID 0 route, an unverified server convention.
        //   - completion: Result of `StatusResponse` or `TMDBError`

        public func markAsFavorite(_ isFavorite: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>) {
            let favorite = FavoriteMedia(mediaType: media.type, mediaId: media.id, favorite: isFavorite)
            tmdb.authenticatedRequestAndParse(Account.markFavorite(accountId: accountId, media: favorite), completion: completion)
        }

        /// Add a movie or TV show to your watchlist.
        ///
        /// - Parameters:
        ///   - toWatchlist: Whether the item should be added or removed from watchlist.
        ///   - media: The media to be added or removed from watchlist.
        ///   - accountId: The `accountId`, of the user. Nil preserves the legacy ID 0 route, an unverified server convention.
        ///   - completion: Result of `StatusResponse` or `TMDBError`
        public func addToWatchlist(_ toWatchlist: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>) {
            let watchlist = WatchlistMedia(mediaType: media.type, mediaId: media.id, watchlist: toWatchlist)
            tmdb.authenticatedRequestAndParse(Account.addToWatchlist(accountId: accountId, media: watchlist), completion: completion)
        }
    }
}
