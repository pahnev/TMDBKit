//
//  PeopleEnpointTests.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import XCTest
@testable import TMDBKit

class PeopleEndpointTests: TMDBTestCase {
    private let personId = 1

    func testReturnsPersonDetails() throws {
        try stubHelper.stubWithLocalFile(People.details(personId: personId, language: nil, append: nil))

        let person = try awaitFor { tmdb.people.details(for: personId, appending: nil, completion: $0) }.value

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "George Lucas")
    }

    func testReturnsPersonChanges() throws {
        try stubHelper.stubWithLocalFile(People.changes(personId: personId, pageNumber: 1))

        let changes = try awaitFor { tmdb.people.changes(for: personId, completion: $0) }.value

        XCTAssertNotNil(changes)
    }

    func testReturnsMovieCredits() throws {
        try stubHelper.stubWithLocalFile(People.movieCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.movieCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
    }

    func testReturnsTVCredits() throws {
        try stubHelper.stubWithLocalFile(People.tvCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.tvCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
    }

    func testReturnsCombinedCredits() throws {
        try stubHelper.stubWithLocalFile(People.combinedCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.combinedCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(People.externalIds(personId: personId, language: nil))

        let ids = try awaitFor { tmdb.people.externalIds(for: personId, completion: $0) }.value

        XCTAssertNotNil(ids)
    }

    func testReturnsImages() throws {
        try stubHelper.stubWithLocalFile(People.images(personId: personId))

        let images = try awaitFor { tmdb.people.images(for: personId, completion: $0) }.value

        XCTAssertNotNil(images)
    }

    func testReturnsTaggedImages() throws {
        try stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil))

        let images = try awaitFor { tmdb.people.taggedImages(for: personId, completion: $0) }.value

        XCTAssertNotNil(images)
    }

    func testTaggedImagesResponseParsing() throws {
        try stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil))

        let images = try awaitFor { tmdb.people.taggedImages(for: personId, completion: $0) }.value

        XCTAssertNotNil(images)
        XCTAssertEqual(images?.id, 19)
        XCTAssertEqual(images?.page, 1)
        XCTAssertEqual(images?.totalPages, 1)
        XCTAssertEqual(images?.results.count, 10)

        let tvResult = try XCTUnwrap(images?.results.first)

        XCTAssertEqual(tvResult.voteCount, 3)
        XCTAssertEqual(tvResult.mediaType, .tv)
        XCTAssertEqual(tvResult.filePath, "/hY0TRC5cXMqFQvm5xl5LLd9t7eX.jpg")
        XCTAssertEqual(tvResult.aspectRatio, 1.7778, accuracy: 0.0001)
        XCTAssertEqual(tvResult.height, 1080)
        XCTAssertEqual(tvResult.voteAverage, 5.4401, accuracy: 0.0001)
        XCTAssertEqual(tvResult.width, 1920)

        switch tvResult.media {
        case .movie(let movie):
            XCTAssertNil(movie)
        case .tv(let tvMedia):
            XCTAssertEqual(tvMedia.name, "The West Wing")
            XCTAssertEqual(tvMedia.posterPath, "/nJKhLuvlhBOY5ckeUG4caD7JdP8.jpg")
        case .person(let person):
            XCTAssertNil(person)
        }
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(People.translations(personId: personId, language: nil))

        let translations = try awaitFor { tmdb.people.translations(for: personId, completion: $0) }.value

        XCTAssertNotNil(translations)
    }

    func testReturnsLatest() throws {
        try stubHelper.stubWithLocalFile(People.latest(language: nil))

        let person = try awaitFor { tmdb.people.latest(completion: $0) }.value

        XCTAssertNotNil(person)
    }

    func testReturnsPopular() throws {
        try stubHelper.stubWithLocalFile(People.popular(pageNumber: 1, language: nil))

        let person = try awaitFor { tmdb.people.popular(completion: $0) }.value

        XCTAssertNotNil(person)
    }

    func test_httpMethod() {
        XCTAssertEqual(People.details(personId: personId, language: nil, append: nil).httpMethod, .GET)
        XCTAssertEqual(People.changes(personId: personId, pageNumber: 1).httpMethod, .GET)
        XCTAssertEqual(People.movieCredits(personId: personId, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.tvCredits(personId: personId, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.combinedCredits(personId: personId, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.externalIds(personId: personId, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.images(personId: personId).httpMethod, .GET)
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.translations(personId: personId, language: nil).httpMethod, .GET)
        XCTAssertEqual(People.latest(language: nil).httpMethod, .GET)
        XCTAssertEqual(People.popular(pageNumber: 1, language: nil).httpMethod, .GET)
    }

    func test_httpBody() {
        XCTAssertNil(People.details(personId: personId, language: nil, append: nil).httpBody)
        XCTAssertNil(People.changes(personId: personId, pageNumber: 1).httpBody)
        XCTAssertNil(People.movieCredits(personId: personId, language: nil).httpBody)
        XCTAssertNil(People.tvCredits(personId: personId, language: nil).httpBody)
        XCTAssertNil(People.combinedCredits(personId: personId, language: nil).httpBody)
        XCTAssertNil(People.externalIds(personId: personId, language: nil).httpBody)
        XCTAssertNil(People.images(personId: personId).httpBody)
        XCTAssertNil(People.taggedImages(personId: personId, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(People.translations(personId: personId, language: nil).httpBody)
        XCTAssertNil(People.latest(language: nil).httpBody)
        XCTAssertNil(People.popular(pageNumber: 1, language: nil).httpBody)
    }

    func test_endpointHeaders() {
        XCTAssertEqual(People.details(personId: personId, language: nil, append: nil).requestHeaders, [:])
        XCTAssertEqual(People.changes(personId: personId, pageNumber: 1).requestHeaders, [:])
        XCTAssertEqual(People.movieCredits(personId: personId, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.tvCredits(personId: personId, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.combinedCredits(personId: personId, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.externalIds(personId: personId, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.images(personId: personId).requestHeaders, [:])
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.translations(personId: personId, language: nil).requestHeaders, [:])
        XCTAssertEqual(People.latest(language: nil).requestHeaders, [:])
        XCTAssertEqual(People.popular(pageNumber: 1, language: nil).requestHeaders, [:])
    }

    func test_urlConstruction() {
        XCTAssertEqual(People.details(personId: personId, language: nil, append: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1")
        XCTAssertEqual(People.details(personId: personId, language: "en", append: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?language=en")
        XCTAssertEqual(People.details(personId: personId, language: nil, append: [.credits]).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?append_to_response=credits")
        XCTAssertEqual(People.details(personId: personId, language: nil, append: [.recommendations, .credits]).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?append_to_response=recommendations,credits")
        XCTAssertEqual(People.details(personId: personId, language: "en", append: [.translations, .similar]).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?language=en&append_to_response=translations,similar")

        XCTAssertEqual(People.changes(personId: personId, pageNumber: 1).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/changes?page=1")
        XCTAssertEqual(People.changes(personId: personId, pageNumber: 2).url.absoluteString,
                          "https://api.themoviedb.org/3/person/1/changes?page=2")

        XCTAssertEqual(People.movieCredits(personId: personId, language: nil).url.absoluteString,
                          "https://api.themoviedb.org/3/person/1/movie_credits")
        XCTAssertEqual(People.movieCredits(personId: personId, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/movie_credits?language=en")

        XCTAssertEqual(People.tvCredits(personId: personId, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/tv_credits")
        XCTAssertEqual(People.tvCredits(personId: personId, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/tv_credits?language=en")

        XCTAssertEqual(People.combinedCredits(personId: personId, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/combined_credits")
        XCTAssertEqual(People.combinedCredits(personId: personId, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/combined_credits?language=en")

        XCTAssertEqual(People.externalIds(personId: personId, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/external_ids")
        XCTAssertEqual(People.externalIds(personId: personId, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/external_ids?language=en")

        XCTAssertEqual(People.images(personId: personId).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/images")

        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/tagged_images?page=1")
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 2, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/tagged_images?page=2")
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/tagged_images?page=1&language=en")

        XCTAssertEqual(People.translations(personId: personId, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/translations")
        XCTAssertEqual(People.translations(personId: personId, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/1/translations?language=en")

        XCTAssertEqual(People.latest(language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/latest")
        XCTAssertEqual(People.latest(language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/latest?language=en")
        
        XCTAssertEqual(People.popular(pageNumber: 1, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/popular?page=1")
        XCTAssertEqual(People.popular(pageNumber: 2, language: nil).url.absoluteString,
                            "https://api.themoviedb.org/3/person/popular?page=2")
        XCTAssertEqual(People.popular(pageNumber: 1, language: "en").url.absoluteString,
                            "https://api.themoviedb.org/3/person/popular?page=1&language=en")
    }
}
