//
//  AccountEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import CoreFoundation
import XCTest
@testable import TMDBKit

class AccountEndpointTests: TMDBTestCase {

    func testAccountDetailsExplicitIDUsesDocumentedPath() throws {
        try assertGETQuery("/3/account/548", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456")]) {
            tmdb.account.details(for: 548, completion: $0)
        }
        tmdb = makeTMDB(authenticator: MockAuth(sessionId: nil))
        try assertGETQuery("/3/account/548", [URLQueryItem(name: "api_key", value: "123")]) {
            tmdb.account.details(for: 548, completion: $0)
        }
        XCTAssertEqual(Account.detailsFor(accountId: 0).url.path, "/3/account/0")
        XCTAssertEqual(Account.detailsFor(accountId: -1).url.path, "/3/account/-1")
    }

    func testLegacyAccountDefaultsRemainDocumentedCompatibility() throws {
        // Local non-contract coverage: /account and nil -> 0 are unverified server conventions.
        let auth = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456")]
        try assertGETQuery("/3/account", auth) { tmdb.account.details(completion: $0) }
        try assertGETQuery("/3/account/0/favorite/movies", auth) { tmdb.account.favoriteMoviesFor(pageNumber: nil, completion: $0) }
        try assertGETQuery("/3/account/548/favorite/movies", auth) { tmdb.account.favoriteMoviesFor(accountId: 548, pageNumber: nil, completion: $0) }
    }
    func testLegacyUndocumentedQueriesAreOmitted() throws {
        let authenticated = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456")]
        try assertGETQuery("/3/account/1/lists", authenticated + [URLQueryItem(name: "page", value: "2")]) {
            tmdb.account.createdListsFor(accountId: 1, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.ascending), completion: $0)
        }
        try assertGETQuery("/3/account/1/lists", authenticated) {
            tmdb.account.createdListsFor(accountId: 1, pageNumber: nil, completion: $0)
        }
    }

    func testDetailsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.details, expecting: .init(path: "/3/account", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.details(completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.id, 548)
        XCTAssertEqual(details?.name, "Travis Bell")
    }

    func testCreatedListsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/lists", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.createdListsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 4)
        XCTAssertEqual(details?.object.totalResults, 61)
        XCTAssertEqual(details?.object.results.first?.id, 10)
    }

    func testFavoriteMoviesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/favorite/movies", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.favoriteMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 4)
        XCTAssertEqual(details?.object.totalResults, 77)
        XCTAssertEqual(details?.object.results.first?.id, 9806)
    }

    func testFavoriteTVShowsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/favorite/tv", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.favoriteTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 3)
        XCTAssertEqual(details?.object.totalResults, 52)
        XCTAssertEqual(details?.object.results.first?.id, 1404)
    }

    func testRatedMoviesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/rated/movies", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.ratedMoviesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 31)
        XCTAssertEqual(details?.object.totalResults, 605)
        XCTAssertEqual(details?.object.results.first?.id, 155)
    }

    func testRatedTVShowsRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/rated/tv", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.ratedTVShowsFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 7)
        XCTAssertEqual(details?.object.totalResults, 139)
        XCTAssertEqual(details?.object.results.first?.id, 1705)
    }

    func testRatedTVEpisodesRequest() throws {
        try stubHelper.stubWithLocalFile(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/rated/tv/episodes", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.ratedTVEpisodesFor(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 8)
        XCTAssertEqual(details?.object.totalResults, 152)
        XCTAssertEqual(details?.object.results.first?.id, 64782)
    }

    func testMovieWatchlistRequest() throws {
        try stubHelper.stubWithLocalFile(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/watchlist/movies", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.movieWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 14)
        XCTAssertEqual(details?.object.totalResults, 277)
        XCTAssertEqual(details?.object.results.first?.id, 76726)
    }

    func testTVShowWatchlistRequest() throws {
        try stubHelper.stubWithLocalFile(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil), expecting: .init(path: "/3/account/1/watchlist/tv", query: ["api_key": "123", "session_id": "456"]))

        let details = try awaitFor { tmdb.account.tvShowWatchlist(accountId: 1, pageNumber: nil, completion: $0) }.value

        XCTAssertNotNil(details)
        XCTAssertEqual(details?.object.page, 1)
        XCTAssertEqual(details?.object.totalPages, 4)
        XCTAssertEqual(details?.object.totalResults, 64)
        XCTAssertEqual(details?.object.results.first?.id, 58932)
    }

    func test_httpMethod() {
        XCTAssertEqual(Account.details.httpMethod, .GET)
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpMethod, .GET)
        XCTAssertEqual(Account.markFavorite(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, favorite: true)).httpMethod, .POST)
        XCTAssertEqual(Account.addToWatchlist(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, watchlist: true)).httpMethod, .POST)
    }

    func test_httpBody() {
        // Test body is correct for each case
        XCTAssertNil(Account.details.httpBody)
        XCTAssertNil(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNil(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).httpBody)
        XCTAssertNotNil(Account.markFavorite(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, favorite: true)).httpBody)
        XCTAssertNotNil(Account.addToWatchlist(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, watchlist: true)).httpBody)
    }

    func test_markFavorite_httpBody() throws {
        let media = FavoriteMedia(mediaType: .movie, mediaId: 1, favorite: true)
        let body = try XCTUnwrap(Account.markFavorite(accountId: nil, media: media).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["media_type", "media_id", "favorite"]))
        XCTAssertEqual(object["media_type"] as? String, "movie")
        let number = try XCTUnwrap(object["media_id"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
        XCTAssertEqual(number.doubleValue, 1)
        let flag = try XCTUnwrap(object["favorite"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(flag), CFBooleanGetTypeID())
        XCTAssertEqual(flag.boolValue, true)
    }

    func test_addToWatchList_httpBody() throws {
        let media = WatchlistMedia(mediaType: .movie, mediaId: 1, watchlist: true)
        let body = try XCTUnwrap(Account.addToWatchlist(accountId: nil, media: media).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["media_type", "media_id", "watchlist"]))
        XCTAssertEqual(object["media_type"] as? String, "movie")
        let number = try XCTUnwrap(object["media_id"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
        XCTAssertEqual(number.doubleValue, 1)
        let flag = try XCTUnwrap(object["watchlist"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(flag), CFBooleanGetTypeID())
        XCTAssertEqual(flag.boolValue, true)
    }

    func test_requestHeaders() {
        XCTAssertEqual(Account.details.requestHeaders, [:])
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])
        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).requestHeaders, [:])

        let expectedHeaders = ["Content-Type": "application/json;charset=utf-8"]
        XCTAssertEqual(Account.markFavorite(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, favorite: true)).requestHeaders, expectedHeaders)
        XCTAssertEqual(Account.addToWatchlist(accountId: nil, media: .init(mediaType: .movie, mediaId: 1, watchlist: true)).requestHeaders, expectedHeaders)
    }

    func test_urlConstruction() {
        // Verify URL is correct for each case in all variations
        XCTAssertEqual(Account.details.url, URL(string: "https://api.themoviedb.org/3/account"))

        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/lists"))
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/lists"))
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/lists?page=2"))
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/lists?page=2"))

        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/movies"))
        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/movies?sort_by=created_at.asc"))
        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/movies?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.favoriteMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/movies?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/tv"))
        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/tv?sort_by=created_at.asc"))
        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/tv?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.favoriteTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/favorite/tv?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/movies"))
        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/movies?sort_by=created_at.asc"))
        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/movies?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.ratedMovies(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/rated/movies?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv"))
        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv?sort_by=created_at.asc"))
        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.ratedTVShows(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv/episodes"))
        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv/episodes?sort_by=created_at.asc"))
        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv/episodes?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.ratedTVEpisodes(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/rated/tv/episodes?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/movies"))
        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/movies?sort_by=created_at.asc"))
        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/movies?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.movieWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/movies?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: nil, page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/tv"))
        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/tv?sort_by=created_at.asc"))
        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/tv?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.tvShowWatchlist(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist/tv?sort_by=created_at.asc&page=2&language=en"))

        XCTAssertEqual(Account.markFavorite(accountId: 1, media: .init(mediaType: .movie, mediaId: 1, favorite: true)).url, URL(string: "https://api.themoviedb.org/3/account/1/favorite"))
        XCTAssertEqual(Account.addToWatchlist(accountId: 1, media: .init(mediaType: .movie, mediaId: 1, watchlist: true)).url, URL(string: "https://api.themoviedb.org/3/account/1/watchlist"))
    }
}

extension AccountEndpointTests {
    func testExplicitAccountDetailsReturnsFields() throws {
        stubResponse(try contractObject("account-details")) { request in
            try RequestExpectation(path: "/3/account/548", query: ["api_key": "123", "session_id": "456"]).assertRequest(request)
        }
        let account = try XCTUnwrap(awaitFor { tmdb.account.details(for: 548, completion: $0) }.value)
        XCTAssertEqual(account.id, 548)
        XCTAssertEqual(account.name, "Travis Bell")
    }

    func testMarkFavoriteRequestAndResponse() throws {
        stubResponse(["status_code": 1, "status_message": "Success."]) { request in
            try RequestExpectation(path: "/3/account/548/favorite", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["media_type": "movie", "media_id": 550, "favorite": true], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.account.markAsFavorite(true, media: .init(type: .movie, id: 550), for: 548, completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 1)
        XCTAssertEqual(response.statusMessage, "Success.")
    }

    func testAddToWatchlistRequestAndResponse() throws {
        stubResponse(["status_code": 13, "status_message": "Deleted."]) { request in
            try RequestExpectation(path: "/3/account/548/watchlist", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["media_type": "tv", "media_id": 1399, "watchlist": false], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.account.addToWatchlist(false, media: .init(type: .tv, id: 1399), for: 548, completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 13)
        XCTAssertEqual(response.statusMessage, "Deleted.")
    }
}

extension AccountEndpointTests {
    func testcreatedListsForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/lists", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2")]) {
            tmdb.account.createdListsFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testfavoriteMoviesForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/favorite/movies", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.favoriteMoviesFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testfavoriteTVShowsForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/favorite/tv", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.favoriteTVShowsFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testratedMoviesForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/rated/movies", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.ratedMoviesFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testratedTVShowsForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/rated/tv", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.ratedTVShowsFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testratedTVEpisodesForNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/rated/tv/episodes", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.ratedTVEpisodesFor(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testmovieWatchlistNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/watchlist/movies", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.movieWatchlist(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

    func testtvShowWatchlistNondefaultOptions() throws {
        try assertGETQuery("/3/account/548/watchlist/tv", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "sort_by", value: "created_at.desc")]) {
            tmdb.account.tvShowWatchlist(accountId: 548, pageNumber: 2, language: "fi-FI", sortBy: .createdAt(.descending), completion: $0)
        }
    }

}
