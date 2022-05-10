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
}
