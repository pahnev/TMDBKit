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

        /// Get your account details.
        ///
        /// - Parameter completion: Result of `AccountDetails` or `TMDBError`
        public func details(completion: @escaping TMDBResult<AccountDetails>) {
            tmdb.authenticatedRequestAndParse(Account.details, completion: completion)
        }

        /// Get all the lists created by an account. Will include private lists if you are the owner.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose lists to fetch. Nil by default will return the logged in user's lists.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `ListsResponse` or `TMDBError`
        public func createdListsFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<ListsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.createdLists(accountId: accountId,
                                                                            pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get the list of your favorite movies.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose favorite movies fetch. Nil by default will return the logged in user's favorite movies.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `HTTPResponseContaining<PopularMoviesResponse>` or `TMDBError`
        public func favoriteMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.favoriteMovies(accountId: accountId,
                                                                              pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get the list of your favorite TV shows.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose favorite TV shows fetch. Nil by default will return the logged in user's favorite TV shows.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func favoriteTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.favoriteTVShows(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get a list of all the movies you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated movies fetch. Nil by default will return the logged in user's rated movies.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
        public func ratedMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedMovies(accountId: accountId,
                                                                           pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get a list of all the TV shows you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated TV shows fetch. Nil by default will return the logged in user's rated TV shows.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func ratedTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedTVShows(accountId: accountId,
                                                                            pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get a list of all the TV episodes you have rated.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose rated TV episodes fetch. Nil by default will return the logged in user's rated TV episodes.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `EpisodeListResponse` or `TMDBError`
        public func ratedTVEpisodesFor(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<EpisodeListResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.ratedTVEpisodes(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get a list of all the movies you have added to your watchlist.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose movie watchlist to fetch. Nil by default will return the logged in user's movie watchlist.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
        public func movieWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.movieWatchlist(accountId: accountId,
                                                                              pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        /// Get a list of all the TV shows you have added to your watchlist.
        ///
        /// - Parameters:
        ///   - accountId: The `accountId` whose TV show watchlist to fetch. Nil by default will return the logged in user's TV show watchlist.
        ///   - pageNumber: The number of the page if fetching paginated results.
        ///   - completion: Result of `SimilarShowsResponse` or `TMDBError`
        public func tvShowWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>) {
            tmdb.authenticatedRequestWithResponse(for: Account.tvShowWatchlist(accountId: accountId,
                                                                               pagination: SortedPagination(sortBy: nil, page: pageNumber)),
                                                  completion: completion)
        }

        // MARK: - POST

        /// This method allows you to mark a movie or TV show as a favorite item.
        ///
        /// - Parameters:
        ///   - isFavorite: Whether the item should be added or removed from favorites list.
        ///   - media: The media to be added or removed from favorites list.
        ///   - accountId: The `accountId`, of the user. `nil` by default, will add to currently logged in user's list.
        ///   - completion: Result of `StatusResponse` or `TMDBError`

        public func markAsFavorite(_ isFavorite: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>) {
            let favorite = FavoriteMedia(mediaType: media.type, mediaId: media.id, favorite: isFavorite)
            tmdb.authenticatedRequestAndParse(Account.markFavorite(accountId: accountId, media: favorite), completion: completion)
        }

        /// Add a movie or TV show to your watchlist.
        ///
        /// - Parameters:
        ///   - toWatchlist: Whether the item should be added or removed from watchlist.
        ///   - media: The media to be added or removed from watchlist.
        ///   - accountId: The `accountId`, of the user. `nil` by default, will add to currently logged in user's list.
        ///   - completion: Result of `StatusResponse` or `TMDBError`
        public func addToWatchlist(_ toWatchlist: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>) {
            let watchlist = WatchlistMedia(mediaType: media.type, mediaId: media.id, watchlist: toWatchlist)
            tmdb.authenticatedRequestAndParse(Account.addToWatchlist(accountId: accountId, media: watchlist), completion: completion)
        }
    }
}
