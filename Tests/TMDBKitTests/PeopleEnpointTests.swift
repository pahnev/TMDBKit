//
//  File.swift
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
}
