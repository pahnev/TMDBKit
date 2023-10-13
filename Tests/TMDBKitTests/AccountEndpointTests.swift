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
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(media)

        let body = Account.markFavorite(accountId: nil, media: media).httpBody
        XCTAssertEqual(body, data)
    }

    func test_addToWatchList_httpBody() throws {
        let media = WatchlistMedia(mediaType: .movie, mediaId: 1, watchlist: true)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(media)

        let body = Account.addToWatchlist(accountId: nil, media: media).httpBody
        XCTAssertEqual(body, data)
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
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: nil), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/lists?sort_by=created_at.asc"))
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: nil).url, URL(string: "https://api.themoviedb.org/3/account/1/lists?sort_by=created_at.asc&page=2"))
        XCTAssertEqual(Account.createdLists(accountId: 1, pagination: SortedPagination(sortBy: .createdAt(.ascending), page: 2), language: "en").url, URL(string: "https://api.themoviedb.org/3/account/1/lists?sort_by=created_at.asc&page=2&language=en"))

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
