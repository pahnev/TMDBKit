//
//  AccountEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Nimble
import XCTest
@testable import TMDBKit

class AccountEndpointTests: TMDBTestCase {
    func testDetailsRequest() throws {
        stubHelper.stubWithLocalFile(Account.details)

        let details = try awaitFor { tmdb.account.details(completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testCreatedListsRequest() throws {
        stubHelper.stubWithLocalFile(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.createdListsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testFavoriteMoviesRequest() throws {
        stubHelper.stubWithLocalFile(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.favoriteMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testFavoriteTVShowsRequest() throws {
        stubHelper.stubWithLocalFile(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.favoriteTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testRatedMoviesRequest() throws {
        stubHelper.stubWithLocalFile(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.ratedMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testRatedTVShowsRequest() throws {
        stubHelper.stubWithLocalFile(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.ratedTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testRatedTVEpisodesRequest() throws {
        stubHelper.stubWithLocalFile(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.ratedTVEpisodesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testMovieWatchlistRequest() throws {
        stubHelper.stubWithLocalFile(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.movieWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }

    func testTVShowWatchlistRequest() throws {
        stubHelper.stubWithLocalFile(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil)))

        let details = try awaitFor { tmdb.account.tvShowWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        expect(details).toEventuallyNot(beNil())
    }
}
