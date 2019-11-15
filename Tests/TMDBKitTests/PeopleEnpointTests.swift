//
//  File.swift
//  
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import XCTest
import Nimble
import OHHTTPStubsSwift
@testable import TMDBKit

class PeopleEndpointTests: XCTestCase {

    private var stubHelper: StubHelper!
    private var tmdb: TMDB!
    private let personId = 1

    override func setUp() {
        guard let tmdb = try? TMDB(authenticator: MockAuth()) else { preconditionFailure() }
        self.tmdb = tmdb
        self.stubHelper = StubHelper()
        super.setUp()
    }

    override func tearDown() {
        tmdb.clearCaches()
        super.tearDown()
    }

    func testReturnsPersonDetails() {
        var person: PersonDetailsResponse?
        stubHelper.stubWithLocalFile(People.details(personId: personId, append: nil))
        tmdb.people.details(for: personId, appending: nil) { result in
            person = result.value
        }
        expect(person).toEventuallyNot(beNil())
        expect(person?.name).toEventually(equal("George Lucas"))
    }

    func testReturnsPersonChanges() {
        var changes: ChangesResponse?
        stubHelper.stubWithLocalFile(People.changes(personId: personId))
        tmdb.people.changes(for: personId) { result in
            changes = result.value
        }
        expect(changes).toEventuallyNot(beNil())
    }

    func testReturnsMovieCredits() {
        var credits: PersonCreditsResponse?
        stubHelper.stubWithLocalFile(People.movieCredits(personId: personId))
        tmdb.people.movieCredits(for: personId) { result in
            credits = result.value
        }
        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsTVCredits() {
        var credits: PersonCreditsResponse?
        stubHelper.stubWithLocalFile(People.tvCredits(personId: personId))
        tmdb.people.tvCredits(for: personId) { result in
            credits = result.value
        }
        expect(credits).toEventuallyNot(beNil())
    }
    func testReturnsCombinedCredits() {
        var credits: PersonCreditsResponse?
        stubHelper.stubWithLocalFile(People.combinedCredits(personId: personId))
        tmdb.people.combinedCredits(for: personId) { result in
            credits = result.value
        }
        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() {
        var ids: ExternalIds?
        stubHelper.stubWithLocalFile(People.externalIds(personId: personId))
        tmdb.people.externalIds(for: personId) { result in
            ids = result.value
        }
        expect(ids).toEventuallyNot(beNil())
    }

    func testReturnsImages() {
        var images: PersonImageResponse?
        stubHelper.stubWithLocalFile(People.images(personId: personId))
        tmdb.people.images(for: personId) { result in
            images = result.value
        }
        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsTaggedImages() {
        var images: TaggedImageResponse?
        stubHelper.stubWithLocalFile(People.taggedImages(personId: personId))
        tmdb.people.taggedImages(for: personId) { result in
            images = result.value
        }
        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsTranslations() {
        var translations: PersonTranslationResponse?
        stubHelper.stubWithLocalFile(People.translations(personId: personId))
        tmdb.people.translations(for: personId) { result in
            translations = result.value
        }
        expect(translations).toEventuallyNot(beNil())
    }
    
    func testReturnsLatest() {
        var person: PersonDetailsResponse?
        stubHelper.stubWithLocalFile(People.latest)
        tmdb.people.latest { result in
            person = result.value
        }
        expect(person).toEventuallyNot(beNil())
    }

    func testReturnsPopular() {
        var person: PopularPersonResponse?
        stubHelper.stubWithLocalFile(People.popular)
        tmdb.people.popular { result in
            person = result.value
        }
        expect(person).toEventuallyNot(beNil())
    }
}
