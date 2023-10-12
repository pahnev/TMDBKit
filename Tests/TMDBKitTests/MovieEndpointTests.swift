//
//  MovieEndpointTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import XCTest
@testable import TMDBKit

class MovieEndpointTests: TMDBTestCase {
    let blackPantherMovieId = 284054
    let allQuietMovieId = 143

    func testReturnsMovieDetails() throws {
        try stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: nil, language: nil))

        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: nil, completion: $0) }.value

        XCTAssertNotNil(movie)
    }

    func testReturnsMovieDetailsWithAllExtraDetails() throws {
        try stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: DetailsAppendable.allCases, language: nil))
        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: DetailsAppendable.allCases, completion: $0) }.value

        XCTAssertNotNil(movie?.reviews)
        XCTAssertNotNil(movie?.videos)
        XCTAssertNotNil(movie?.images)
        XCTAssertNotNil(movie?.credits)
        XCTAssertNotNil(movie?.recommendations)
        XCTAssertNotNil(movie?.similar)
        XCTAssertNotNil(movie?.translations)
    }

    func testReturnsAccountsStatesForMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.accountStates(movieId: blackPantherMovieId))

        let result = try awaitFor { tmdb.movies.accountStates(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 284054)
        XCTAssertNil(result?.rated)
    }

    func testReturnsAccountsStatesForMovieWithRating() throws {
        try stubHelper.stubWithLocalFile(Movies.accountStates(movieId: allQuietMovieId))

        let result = try awaitFor { tmdb.movies.accountStates(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.rated?.value, 3.0)
    }

    func testReturnsAlternativeTitlesForMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.alternativeTitles(movieId: allQuietMovieId, country: nil))

        let alternatives = try awaitFor { tmdb.movies.alternativeTitles(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(alternatives)
    }

    func testReturnsChanges() throws {
        try stubHelper.stubWithLocalFile(Movies.changes(movieId: allQuietMovieId))

        let changes = try awaitFor { tmdb.movies.changes(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(changes)
    }

    func testReturnsCredits() throws {
        try stubHelper.stubWithLocalFile(Movies.credits(movieId: blackPantherMovieId, language: nil))

        let credits = try awaitFor { tmdb.movies.credits(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(credits)
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(Movies.externalIds(movieId: blackPantherMovieId))

        let ids = try awaitFor { tmdb.movies.externalIds(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(ids)
    }

    func testReturnsMovieImages() throws {
        try stubHelper.stubWithLocalFile(Movies.images(movieId: blackPantherMovieId, language: nil))

        let images = try awaitFor { tmdb.movies.images(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(images)
    }

    func testReturnsKeywords() throws {
        try stubHelper.stubWithLocalFile(Movies.keywords(movieId: blackPantherMovieId))

        let words = try awaitFor { tmdb.movies.keywords(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(words)
    }

    func testReturnsReleaseDates() throws {
        try stubHelper.stubWithLocalFile(Movies.releaseDates(movieId: blackPantherMovieId))

        let dates = try awaitFor { tmdb.movies.releaseDates(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(dates)
    }

    func testReturnsVideos() throws {
        try stubHelper.stubWithLocalFile(Movies.videos(movieId: blackPantherMovieId, language: nil))

        let videos = try awaitFor { tmdb.movies.videos(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(videos)
    }

    func testReturnsWatchProviders() throws {
        try stubHelper.stubWithLocalFile(Movies.watchProviders(movieId: blackPantherMovieId))

        let providers = try awaitFor { tmdb.movies.watchProviders(for: blackPantherMovieId, completion: $0) }.value
        XCTAssertNotNil(providers)

        let finnishProviders = providers?.results?.fi
        XCTAssertEqual(finnishProviders?.link, "https://www.themoviedb.org/movie/284054-black-panther/watch?locale=FI")
        XCTAssertEqual(finnishProviders?.buy?.count, 8)
        XCTAssertEqual(finnishProviders?.rent?.count, 5)
        XCTAssertEqual(finnishProviders?.flatrate?.count, 1)
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(Movies.translations(movieId: blackPantherMovieId))

        let translations = try awaitFor { tmdb.movies.translations(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(translations)
    }

    func testReturnsRecommendations() throws {
        try stubHelper.stubWithLocalFile(Movies.recommendations(movieId: blackPantherMovieId, pageNumber: 1, language: nil))

        let movies = try awaitFor { tmdb.movies.recommendations(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
    }

    func testReturnsSimilarMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.similarMovies(movieId: blackPantherMovieId, pageNumber: 1, language: nil))

        let movies = try awaitFor { tmdb.movies.similarMovies(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
    }

    func testReturnsReviews() throws {
        try stubHelper.stubWithLocalFile(Movies.reviews(movieId: blackPantherMovieId, pageNumber: 1, language: nil))

        let reviews = try awaitFor { tmdb.movies.reviews(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(reviews)
    }

    func testReturnsLists() throws {
        try stubHelper.stubWithLocalFile(Movies.lists(movieId: blackPantherMovieId, pageNumber: 1, language: nil))

        let lists = try awaitFor { tmdb.movies.lists(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(lists)
    }

    func testReturnsNowPlayingMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil))

        let nowPlaying = try awaitFor { tmdb.movies.nowPlaying(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(nowPlaying)
    }

    func testReturnsLatestMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.latest(language: nil))

        let movie = try awaitFor { tmdb.movies.latest(completion: $0) }.value

        XCTAssertNotNil(movie)
    }

    func testReturnsPopularMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.popular(pageNumber: 1, language: nil, region: nil))

        let movies = try awaitFor { tmdb.movies.popular(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
    }

    func testReturnsTopRatedMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.topRated(pageNumber: 1, language: nil, region: nil))

        let movies = try awaitFor { tmdb.movies.topRated(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
    }

    func testReturnsUpcomingMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.upcoming(pageNumber: 1, language: nil, region: nil))

        let nowPlaying = try awaitFor { tmdb.movies.upcoming(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(nowPlaying)
    }

    func testEndpointURLsAreConstructedProperly() throws {
        assertURL(.accountStates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/account_states")

        assertURL(.alternativeTitles(movieId: 1, country: "fi"), matches: "https://api.themoviedb.org/3/movie/1/alternative_titles?country=fi")

        assertURL(.changes(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/changes")

        assertURL(.credits(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/credits?language=fi")

        assertURL(.deleteRating(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.details(movieId: 1, append: nil, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1?language=fi")

        assertURL(.externalIds(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/external_ids")

        assertURL(.images(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/images?language=fi")

        assertURL(.keywords(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/keywords")

        assertURL(.latest(language: "fi"), matches: "https://api.themoviedb.org/3/movie/latest?language=fi")

        assertURL(.lists(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/lists?page=1&language=fi")

        assertURL(.nowPlaying(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/now_playing?page=1&language=fi&region=fi")

        assertURL(.popular(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/popular?page=1&language=fi&region=fi")

        assertURL(.rateMovie(rating: 1, movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.recommendations(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/recommendations?page=1&language=fi")

        assertURL(.releaseDates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/release_dates")

        assertURL(.reviews(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/reviews?page=1&language=fi")

        assertURL(.similarMovies(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/similar_movies?page=1&language=fi")

        assertURL(.topRated(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/top_rated?page=1&language=fi&region=fi")

        assertURL(.translations(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/translations")

        assertURL(.upcoming(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/upcoming?page=1&language=fi&region=fi")

        assertURL(.videos(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/videos?language=fi")
    }

    func testDetailsEndpointURLAppendsDetails() throws {
        let credits = Movies.details(movieId: 1, append: [DetailsAppendable.credits], language: nil)
        assertURL(credits, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=credits")

        let creditsWithLang = Movies.details(movieId: 1, append: [DetailsAppendable.credits], language: "fi")
        assertURL(creditsWithLang, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=credits")

        let similar = Movies.details(movieId: 1, append: [DetailsAppendable.similar], language: nil)
        assertURL(similar, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=similar")

        let recommendations = Movies.details(movieId: 1, append: [DetailsAppendable.recommendations], language: "fi")
        assertURL(recommendations, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=recommendations")

        let translations = Movies.details(movieId: 1, append: [DetailsAppendable.translations], language: "fi")
        assertURL(translations, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=translations")

        let reviews = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: nil)], language: "fi")
        assertURL(reviews, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=reviews")

        let reviews2 = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: "en")], language: nil)
        assertURL(reviews2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=reviews&language=en")

        let videos = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: nil)], language: nil)
        assertURL(videos, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos")

        let videos2 = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: "en")], language: nil)
        assertURL(videos2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos&language=en")

        let images = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: nil)], language: nil)
        assertURL(images, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images")

        let images2 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en"])], language: nil)
        assertURL(images2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en")

        let images3 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en", "fi"])], language: nil)
        assertURL(images3, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en,fi")
    }

    func test_httpMethod() {
        // Verify http method for each case
        XCTAssertEqual(Movies.accountStates(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.alternativeTitles(movieId: 1, country: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.changes(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.credits(movieId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.deleteRating(movieId: 1).httpMethod, .DELETE)
        XCTAssertEqual(Movies.details(movieId: 1, append: nil, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.externalIds(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.images(movieId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.keywords(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.latest(language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.lists(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.popular(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.rateMovie(rating: 1, movieId: 1).httpMethod, .POST)
        XCTAssertEqual(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.releaseDates(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.topRated(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.translations(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.upcoming(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.videos(movieId: 1, language: nil).httpMethod, .GET)
    }

    func test_httpBody() {
        // Verify http body for each case
        XCTAssertNil(Movies.accountStates(movieId: 1).httpBody)
        XCTAssertNil(Movies.alternativeTitles(movieId: 1, country: nil).httpBody)
        XCTAssertNil(Movies.changes(movieId: 1).httpBody)
        XCTAssertNil(Movies.credits(movieId: 1, language: nil).httpBody)
        XCTAssertNil(Movies.deleteRating(movieId: 1).httpBody)
        XCTAssertNil(Movies.details(movieId: 1, append: nil, language: nil).httpBody)
        XCTAssertNil(Movies.externalIds(movieId: 1).httpBody)
        XCTAssertNil(Movies.images(movieId: 1, language: nil).httpBody)
        XCTAssertNil(Movies.keywords(movieId: 1).httpBody)
        XCTAssertNil(Movies.latest(language: nil).httpBody)
        XCTAssertNil(Movies.lists(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.popular(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.releaseDates(movieId: 1).httpBody)
        XCTAssertNil(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.topRated(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.translations(movieId: 1).httpBody)
        XCTAssertNil(Movies.upcoming(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.videos(movieId: 1, language: nil).httpBody)
    }

    func test_rateMovie_httpBody() throws {
        let data = try JSONEncoder().encode(["value": 1])
        let body = Movies.rateMovie(rating: 1, movieId: 1).httpBody
        XCTAssertEqual(body, data)
    }

    func test_requestHeaders() {
        // Verify request headers for each case
        XCTAssertEqual(Movies.accountStates(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.alternativeTitles(movieId: 1, country: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.changes(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.credits(movieId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.details(movieId: 1, append: nil, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.externalIds(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.images(movieId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.keywords(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.latest(language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.lists(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.popular(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.releaseDates(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.topRated(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.translations(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.upcoming(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.videos(movieId: 1, language: nil).requestHeaders, [:])

        let expectedHeaders = ["Content-Type": "application/json;charset=utf-8"]
        XCTAssertEqual(Movies.deleteRating(movieId: 1).requestHeaders, expectedHeaders)
        XCTAssertEqual(Movies.rateMovie(rating: 1, movieId: 1).requestHeaders, expectedHeaders)
    }

    private func assertURL(_ endpoint: Movies, matches expectedValue: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(endpoint.url.absoluteString, expectedValue, file: file, line: line)
    }
}
