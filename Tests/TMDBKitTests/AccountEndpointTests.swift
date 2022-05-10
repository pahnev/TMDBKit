//
//  AccountEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import XCTest
@testable import TMDBKit

class AccountEndpointTests: TMDBTestCase {
    func testDetailsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.details)

        let details = try awaitFor { tmdb.account.details(completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testCreatedListsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.createdListsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testFavoriteMoviesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.favoriteMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testFavoriteTVShowsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.favoriteTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testRatedMoviesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.ratedMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testRatedTVShowsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.ratedTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testRatedTVEpisodesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.ratedTVEpisodesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testMovieWatchlistRequest() throws {
        try stubHelper.stubWithLocalFile(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.movieWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }

    func testTVShowWatchlistRequest() throws {
        try stubHelper.stubWithLocalFile(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil))

        let details = try awaitFor { tmdb.account.tvShowWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
    }
}
