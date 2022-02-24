//
//  File.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import Nimble
import XCTest
@testable import TMDBKit

class PeopleEndpointTests: TMDBTestCase {
    private let personId = 1

    func testReturnsPersonDetails() throws {
        stubHelper.stubWithLocalFile(People.details(personId: personId, language: nil, append: nil))

        let person = try awaitFor { tmdb.people.details(for: personId, appending: nil, completion: $0) }.value

        expect(person).toEventuallyNot(beNil())
        expect(person?.name).toEventually(equal("George Lucas"))
    }

    func testReturnsPersonChanges() throws {
        stubHelper.stubWithLocalFile(People.changes(personId: personId, pageNumber: 1))

        let changes = try awaitFor { tmdb.people.changes(for: personId, completion: $0) }.value

        expect(changes).toEventuallyNot(beNil())
    }

    func testReturnsMovieCredits() throws {
        stubHelper.stubWithLocalFile(People.movieCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.movieCredits(for: personId, completion: $0) }.value

        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsTVCredits() throws {
        stubHelper.stubWithLocalFile(People.tvCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.tvCredits(for: personId, completion: $0) }.value

        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsCombinedCredits() throws {
        stubHelper.stubWithLocalFile(People.combinedCredits(personId: personId, language: nil))

        let credits = try awaitFor { tmdb.people.combinedCredits(for: personId, completion: $0) }.value

        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() throws {
        stubHelper.stubWithLocalFile(People.externalIds(personId: personId, language: nil))

        let ids = try awaitFor { tmdb.people.externalIds(for: personId, completion: $0) }.value

        expect(ids).toEventuallyNot(beNil())
    }

    func testReturnsImages() throws {
        stubHelper.stubWithLocalFile(People.images(personId: personId))

        let images = try awaitFor { tmdb.people.images(for: personId, completion: $0) }.value

        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsTaggedImages() throws {
        stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil))

        let images = try awaitFor { tmdb.people.taggedImages(for: personId, completion: $0) }.value

        expect(images).toEventuallyNot(beNil())
    }

    func testTaggedImagesResponseParsing() throws {
        stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil))

        let images = try awaitFor { tmdb.people.taggedImages(for: personId, completion: $0) }.value

        expect(images).toEventuallyNot(beNil())
        expect(images?.id).to(equal(19))
        expect(images?.page).to(equal(1))
        expect(images?.totalPages).to(equal(1))
        expect(images?.results.count).to(equal(10))

        let tvResult = images!.results.first!
        expect(tvResult.iso6391).to(beNil())

        expect(tvResult.voteCount).to(equal(3))
        expect(tvResult.mediaType).to(equal(.tv))
        expect(tvResult.filePath).to(equal("/hY0TRC5cXMqFQvm5xl5LLd9t7eX.jpg"))
        expect(tvResult.aspectRatio).to(beCloseTo(1.7778))
        expect(tvResult.height).to(equal(1080))
        expect(tvResult.voteAverage).to(beCloseTo(5.4401))
        expect(tvResult.width).to(equal(1920))

        switch tvResult.media {
        case .movie(let movie):
            expect(movie).toEventually(beNil())
        case .tv(let tvMedia):
            expect(tvMedia.name).to(equal("The West Wing"))
            expect(tvMedia.posterPath).to(equal("/nJKhLuvlhBOY5ckeUG4caD7JdP8.jpg"))
        case .person(let person):
            expect(person).toEventually(beNil())
        }
    }

    func testReturnsTranslations() throws {
        stubHelper.stubWithLocalFile(People.translations(personId: personId, language: nil))

        let translations = try awaitFor { tmdb.people.translations(for: personId, completion: $0) }.value

        expect(translations).toEventuallyNot(beNil())
    }

    func testReturnsLatest() throws {
        stubHelper.stubWithLocalFile(People.latest(language: nil))

        let person = try awaitFor { tmdb.people.latest(completion: $0) }.value

        expect(person).toEventuallyNot(beNil())
    }

    func testReturnsPopular() throws {
        stubHelper.stubWithLocalFile(People.popular(pageNumber: 1, language: nil))

        let person = try awaitFor { tmdb.people.popular(completion: $0) }.value

        expect(person).toEventuallyNot(beNil())
    }
}
