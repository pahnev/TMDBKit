//
//  AccountEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Nimble
@testable import TMDBKit
import XCTest

class AccountEndpointTests: TMDBTestCase {
    func testDetailsRequest() {
        stubHelper.stubWithLocalFile(Account.details)

        var details: AccountDetails?
        tmdb.account.details { result in
            details = result.value
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testCreatedListsRequest() {
        stubHelper.stubWithLocalFile(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: ListsResponse?
        tmdb.account.createdListsFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testFavoriteMoviesRequest() {
        stubHelper.stubWithLocalFile(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: PopularMoviesResponse?
        tmdb.account.favoriteMoviesFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testFavoriteTVShowsRequest() {
        stubHelper.stubWithLocalFile(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: SimilarShowsResponse?
        tmdb.account.favoriteTVShowsFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testRatedMoviesRequest() {
        stubHelper.stubWithLocalFile(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: PopularMoviesResponse?
        tmdb.account.ratedMoviesFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testRatedTVShowsRequest() {
        stubHelper.stubWithLocalFile(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: SimilarShowsResponse?
        tmdb.account.ratedTVShowsFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testRatedTVEpisodesRequest() {
        stubHelper.stubWithLocalFile(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: EpisodeListResponse?
        tmdb.account.ratedTVEpisodesFor(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testMovieWatchlistRequest() {
        stubHelper.stubWithLocalFile(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: PopularMoviesResponse?
        tmdb.account.movieWatchlist(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }

    func testTVShowWatchlistRequest() {
        stubHelper.stubWithLocalFile(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        var details: SimilarShowsResponse?
        tmdb.account.tvShowWatchlist(accountId: 1, pageNumber: nil) { result in
            details = result.value?.object
        }
        expect(details).toEventuallyNot(beNil())
    }
}
