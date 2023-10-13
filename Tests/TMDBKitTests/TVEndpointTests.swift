//
//  TVEndpointTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 01/12/2019.
//

import XCTest
@testable import TMDBKit

class TVEndpointTests: TMDBTestCase {
    private let gameOfThrones = 1399

    func testReturnsDetails() throws {
        try stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, language: nil, append: nil))

        let result = try awaitFor { tmdb.tv.details(for: gameOfThrones, appending: nil, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsDetailsWithAppendedData() throws {
        try stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, language: nil, append: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)]))

        let result = try awaitFor {
            tmdb.tv.details(for: gameOfThrones,
                            appending: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)],
                            completion: $0)
        }.value

        XCTAssertNotNil(result?.reviews)
        XCTAssertNotNil(result?.videos)
        XCTAssertNotNil(result?.images)
    }

    func testDetailsURL() throws {
        let withoutAppending = TV.details(tvId: 1, language: nil, append: nil)
        XCTAssertEqual(withoutAppending.url.absoluteString, "https://api.themoviedb.org/3/tv/1")

        let appendingReviews = TV.details(tvId: 1, language: nil, append: [.reviews(language: nil)])
        XCTAssertEqual(appendingReviews.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=reviews")

        let appendingVideos = TV.details(tvId: 1, language: nil, append: [.videos(language: nil)])
        XCTAssertEqual(appendingVideos.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=videos")

        let appendingImages = TV.details(tvId: 1, language: nil, append: [.images(languages: nil)])
        XCTAssertEqual(appendingImages.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=images")

        let appendingEverything = TV.details(tvId: 1, language: nil, append: [
            .reviews(language: "en"),
            .images(languages: ["en", "es"]),
            .videos(language: "en")
        ])
        XCTAssertEqual(appendingEverything.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=reviews,images,videos&language=en&include_image_language=en,es&language=en")
    }

    func test_accountStates() throws {
        try stubHelper.stubWithLocalFile(TV.accountStates(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.accountStates(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func test_aggregateCredits() throws {
        try stubHelper.stubWithLocalFile(TV.aggregateCredits(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.aggregateCredits(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsAlternativeTitles() throws {
        try stubHelper.stubWithLocalFile(TV.alternativeTitles(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.alternativeTitles(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsChanges() throws {
        try stubHelper.stubWithLocalFile(TV.changes(tvId: gameOfThrones, pageNumber: 1))

        let result = try awaitFor { tmdb.tv.changes(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsContentRatings() throws {
        try stubHelper.stubWithLocalFile(TV.contentRatings(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.contentRatings(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsCredits() throws {
        try stubHelper.stubWithLocalFile(TV.credits(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.credits(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsEpisodeGroups() throws {
        try stubHelper.stubWithLocalFile(TV.episodeGroups(tvId: 30983, language: nil))

        let result = try awaitFor { tmdb.tv.episodeGroups(for: 30983, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(TV.externalIds(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.externalIds(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsImages() throws {
        try stubHelper.stubWithLocalFile(TV.images(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.images(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsKeywords() throws {
        try stubHelper.stubWithLocalFile(TV.keywords(tvId: gameOfThrones))

        let result = try awaitFor { tmdb.tv.keywords(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsRecommendations() throws {
        try stubHelper.stubWithLocalFile(TV.recommendations(tvId: gameOfThrones, pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.recommendations(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsReviews() throws {
        try stubHelper.stubWithLocalFile(TV.reviews(tvId: gameOfThrones, pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.reviews(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsScreenedTheatrically() throws {
        try stubHelper.stubWithLocalFile(TV.screenedTheatrically(tvId: gameOfThrones))

        let result = try awaitFor { tmdb.tv.screenedTheatrically(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsSimilarShows() throws {
        try stubHelper.stubWithLocalFile(TV.similarShows(tvId: gameOfThrones, pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.similarShows(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(TV.translations(tvId: gameOfThrones))

        let result = try awaitFor { tmdb.tv.translations(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsVideos() throws {
        try stubHelper.stubWithLocalFile(TV.videos(tvId: gameOfThrones, language: nil))

        let result = try awaitFor { tmdb.tv.videos(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsLatestShows() throws {
        try stubHelper.stubWithLocalFile(TV.latest(language: nil))

        let result = try awaitFor { tmdb.tv.latest(completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsAiringToday() throws {
        try stubHelper.stubWithLocalFile(TV.airingToday(pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.airingToday(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsOnAirShows() throws {
        try stubHelper.stubWithLocalFile(TV.onTheAir(pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.onTheAir(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsPopular() throws {
        try stubHelper.stubWithLocalFile(TV.popular(pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.popular(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func testReturnsTopRated() throws {
        try stubHelper.stubWithLocalFile(TV.topRated(pageNumber: 1, language: nil))

        let result = try awaitFor { tmdb.tv.topRated(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func test_watchProviders() throws {
        try stubHelper.stubWithLocalFile(TV.watchProviders(tvId: gameOfThrones))

        let result = try awaitFor { tmdb.tv.watchProviders(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
    }

    func test_httpMethod() {
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: nil).httpMethod, .GET)
        XCTAssertEqual(TV.accountStates(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).httpMethod, .GET)
        XCTAssertEqual(TV.contentRatings(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.credits(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.externalIds(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.images(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.keywords(tvId: 1).httpMethod, .GET)
        XCTAssertEqual(TV.recommendations(tvId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.reviews(tvId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.screenedTheatrically(tvId: 1).httpMethod, .GET)
        XCTAssertEqual(TV.similarShows(tvId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.translations(tvId: 1).httpMethod, .GET)
        XCTAssertEqual(TV.videos(tvId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.latest(language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.airingToday(pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.onTheAir(pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.popular(pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.topRated(pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(TV.watchProviders(tvId: 1).httpMethod, .GET)
        XCTAssertEqual(TV.rateShow(tvId: 1, rating: 1).httpMethod, .POST)
        XCTAssertEqual(TV.deleteRating(tvId: 1).httpMethod, .DELETE)
    }

    func test_httpBody() {
        XCTAssertNil(TV.details(tvId: 1, language: nil, append: nil).httpBody)
        XCTAssertNil(TV.accountStates(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.aggregateCredits(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.alternativeTitles(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.changes(tvId: 1, pageNumber: 1).httpBody)
        XCTAssertNil(TV.contentRatings(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.credits(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.episodeGroups(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.externalIds(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.images(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.keywords(tvId: 1).httpBody)
        XCTAssertNil(TV.recommendations(tvId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.reviews(tvId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.screenedTheatrically(tvId: 1).httpBody)
        XCTAssertNil(TV.similarShows(tvId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.translations(tvId: 1).httpBody)
        XCTAssertNil(TV.videos(tvId: 1, language: nil).httpBody)
        XCTAssertNil(TV.latest(language: nil).httpBody)
        XCTAssertNil(TV.airingToday(pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.onTheAir(pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.popular(pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.topRated(pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(TV.watchProviders(tvId: 1).httpBody)
        XCTAssertNil(TV.deleteRating(tvId: 1).httpBody)
    }

    func test_rateShow_httpBody() throws {
        let expectedData = try JSONEncoder().encode(["value": 1])
        XCTAssertEqual(TV.rateShow(tvId: 1, rating: 1).httpBody, expectedData)
    }

    func test_requestHeaders() {
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: nil).requestHeaders, [:])
        XCTAssertEqual(TV.accountStates(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).requestHeaders, [:])
        XCTAssertEqual(TV.contentRatings(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.credits(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.externalIds(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.images(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.keywords(tvId: 1).requestHeaders, [:])
        XCTAssertEqual(TV.recommendations(tvId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.reviews(tvId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.screenedTheatrically(tvId: 1).requestHeaders, [:])
        XCTAssertEqual(TV.similarShows(tvId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.translations(tvId: 1).requestHeaders, [:])
        XCTAssertEqual(TV.videos(tvId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.latest(language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.airingToday(pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.onTheAir(pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.popular(pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.topRated(pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(TV.watchProviders(tvId: 1).requestHeaders, [:])
        XCTAssertEqual(TV.deleteRating(tvId: 1).requestHeaders, ["Content-Type": "application/json;charset=utf-8"])
    }

    func test_urlConstruction() {
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1"))
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en"))
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: [.reviews(language: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?append_to_response=reviews"))
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: [.reviews(language: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en&append_to_response=reviews"))
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: [.videos(language: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?append_to_response=videos"))
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: [.videos(language: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en&append_to_response=videos"))
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: [.images(languages: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?append_to_response=images"))
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: [.images(languages: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en&append_to_response=images"))
        XCTAssertEqual(TV.details(tvId: 1, language: nil, append: [.reviews(language: "en"), .videos(language: nil), .images(languages: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?append_to_response=reviews,videos,images&language=en"))
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: [.reviews(language: "en"), .videos(language: nil), .images(languages: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en&append_to_response=reviews,videos,images&language=en"))

        XCTAssertEqual(TV.accountStates(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/account_states"))
        XCTAssertEqual(TV.accountStates(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/account_states?language=en"))

        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/aggregate_credits"))
        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/aggregate_credits?language=en"))

        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/alternative_titles"))
        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/alternative_titles?language=en"))

        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/changes?page=1"))
        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/changes?page=1"))

        XCTAssertEqual(TV.contentRatings(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/content_ratings"))
        XCTAssertEqual(TV.contentRatings(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/content_ratings?language=en"))

        XCTAssertEqual(TV.credits(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/credits"))
        XCTAssertEqual(TV.credits(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/credits?language=en"))

        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/episode_groups"))
        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/episode_groups?language=en"))

        XCTAssertEqual(TV.externalIds(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/external_ids"))
        XCTAssertEqual(TV.externalIds(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/external_ids?language=en"))

        XCTAssertEqual(TV.images(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/images"))
        XCTAssertEqual(TV.images(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/images?language=en"))

        XCTAssertEqual(TV.keywords(tvId: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/keywords"))

        XCTAssertEqual(TV.recommendations(tvId: 1, pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/recommendations?page=1"))
        XCTAssertEqual(TV.recommendations(tvId: 1, pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/recommendations?page=1&language=en"))

        XCTAssertEqual(TV.reviews(tvId: 1, pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/reviews?page=1"))
        XCTAssertEqual(TV.reviews(tvId: 1, pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/reviews?page=1&language=en"))

        XCTAssertEqual(TV.screenedTheatrically(tvId: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/screened_theatrically"))

        XCTAssertEqual(TV.similarShows(tvId: 1, pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/similar?page=1"))
        XCTAssertEqual(TV.similarShows(tvId: 1, pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/similar?page=1&language=en"))

        XCTAssertEqual(TV.translations(tvId: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/translations"))

        XCTAssertEqual(TV.videos(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/videos"))
        XCTAssertEqual(TV.videos(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/videos?language=en"))

        XCTAssertEqual(TV.latest(language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/latest"))
        XCTAssertEqual(TV.latest(language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/latest?language=en"))

        XCTAssertEqual(TV.airingToday(pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/airing_today?page=1"))
        XCTAssertEqual(TV.airingToday(pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/airing_today?page=1&language=en"))

        XCTAssertEqual(TV.onTheAir(pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/on_the_air?page=1"))
        XCTAssertEqual(TV.onTheAir(pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/on_the_air?page=1&language=en"))

        XCTAssertEqual(TV.popular(pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/popular?page=1"))
        XCTAssertEqual(TV.popular(pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/popular?page=1&language=en"))

        XCTAssertEqual(TV.topRated(pageNumber: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/top_rated?page=1"))
        XCTAssertEqual(TV.topRated(pageNumber: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/top_rated?page=1&language=en"))

        XCTAssertEqual(TV.watchProviders(tvId: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/watch/providers"))

        XCTAssertEqual(TV.rateShow(tvId: 1, rating: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/rating"))
        XCTAssertEqual(TV.deleteRating(tvId: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/rating"))
    }
}
