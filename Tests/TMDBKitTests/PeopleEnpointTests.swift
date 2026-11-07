//
//  PeopleEnpointTests.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import XCTest
@testable import TMDBKit

class PeopleEndpointTests: TMDBTestCase {
    func testPersonAppendResourcesUseDocumentedNamespaces() throws {
        try assertGETQuery("/3/person/31", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "append_to_response", value: "combined_credits,movie_credits,tv_credits,images,translations")]) {
            tmdb.people.details(for: 31, appending: [.credits, .movieCredits, .tvCredits, .combinedCredits, .images(languages: nil), .translations, .credits], completion: $0)
        }
    }

    func testAppendUnsupportedPersonResourcesAreOmitted() throws {
        let unsupported: [DetailsAppendable] = [.reviews(language: "fi"), .videos(language: "en"), .similar, .recommendations]
        try assertGETQuery("/3/person/31", [URLQueryItem(name: "api_key", value: "123")]) {
            tmdb.people.details(for: 31, appending: unsupported, completion: $0)
        }
    }

    func testPersonAppendImagesAndTranslationsDecode() throws {
        var object = try contractObject("person-details")
        object["images"] = try contractObject("person-images", omitID: true)
        object["translations"] = try contractObject("translations", omitID: true)
        for resource in ["movie", "tv", "combined"] {
            object[resource + "_credits"] = try contractObject("person-" + resource + "-credits", omitID: true)
        }
        stubResponse(object) { request in
            XCTAssertEqual(request.url?.path, "/3/person/31")
            XCTAssertEqual(request.httpMethod, "GET")
        }
        let person = try XCTUnwrap(awaitFor { tmdb.people.details(for: 31, appending: [.images(languages: nil), .translations, .movieCredits, .tvCredits, .combinedCredits], completion: $0) }.value)
        XCTAssertEqual(person.profileImages?.profiles.first?.filePath, "/cckcYc2v0yh1tc9QjRelptcOBko.jpg")
        XCTAssertEqual(person.personTranslations?.first?.data.name, "Tom Hanks")
        XCTAssertTrue(person.personTranslations?.first?.data.biography.hasPrefix("Thomas Jeffrey Hanks") == true)
        XCTAssertNil(person.images)
        XCTAssertNil(person.translations)
        XCTAssertEqual(person.movieCredits?.cast.first?.id, 13)
        XCTAssertEqual(person.tvCredits?.cast.first?.id, 1900)
        XCTAssertEqual(person.combinedCredits?.cast.first?.mediaType, "movie")
        XCTAssertEqual(person.credits, person.combinedCredits)
    }

    private let personId = 1

    func testLegacyUndocumentedQueriesAreOmitted() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/person/1/external_ids", application) { tmdb.people.externalIds(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/person/1/tagged_images", application + [URLQueryItem(name: "page", value: "2")]) {
            tmdb.people.taggedImages(for: 1, pageNumber: 2, language: "fi-FI", completion: $0)
        }
        try assertGETQuery("/3/person/1/translations", application) { tmdb.people.translations(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/person/latest", application) { tmdb.people.latest(in: "fi-FI", completion: $0) }
    }

    func testChangesForwardsDateRangeAndPage() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/3/person/1/changes")
            let items = try self.queryItems(in: request)
            for (name, value) in [("page", "2"), ("start_date", "2026-11-01"), ("end_date", "2026-11-06")] {
                XCTAssertEqual(items.filter { $0.name == name }.map { $0.value }, [value])
            }
        }
        let result = try awaitFor {
            tmdb.people.changes(for: 1, pageNumber: 2, startDate: "2026-11-01", endDate: "2026-11-06", completion: $0)
        }.value
        XCTAssertNotNil(result)
        XCTAssertEqual(requestCount, 1)
    }

    func testChangesOmitsUnspecifiedDates() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/person/1/changes")
            let items = try self.queryItems(in: request)
            XCTAssertEqual(items.filter { $0.name == "page" }.map { $0.value }, ["1"])
            XCTAssertFalse(items.contains { $0.name == "start_date" || $0.name == "end_date" })
        }
        XCTAssertNotNil(try awaitFor { tmdb.people.changes(for: 1, completion: $0) }.value)
        XCTAssertEqual(requestCount, 1)
    }

    func testReturnsPersonDetails() throws {
        try stubHelper.stubWithLocalFile(People.details(personId: personId, language: nil, append: nil), expecting: .init(path: "/3/person/1"))

        let person = try awaitFor { tmdb.people.details(for: personId, appending: nil, completion: $0) }.value

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "George Lucas")
        XCTAssertEqual(person?.id, 1)
        XCTAssertEqual(person?.name, "George Lucas")
        XCTAssertEqual(person?.imdbId, "nm0000184")
    }

    func testReturnsPersonChanges() throws {
        try stubResponse(contractObject("changes-person")) { request in
            try RequestExpectation(path: "/3/person/1/changes", query: ["api_key": "123", "page": "1"]).assertRequest(request)
        }

        let changes = try awaitFor { tmdb.people.changes(for: personId, completion: $0) }.value

        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.changes?.first?.key, "biography")
    }

    func testReturnsMovieCredits() throws {
        try stubHelper.stubWithLocalFile(People.movieCredits(personId: personId, language: nil), expecting: .init(path: "/3/person/1/movie_credits"))

        let credits = try awaitFor { tmdb.people.movieCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
        XCTAssertEqual(credits?.id, 1)
        XCTAssertEqual(credits?.cast.first?.character, "Himself")
    }

    func testReturnsTVCredits() throws {
        try stubHelper.stubWithLocalFile(People.tvCredits(personId: personId, language: nil), expecting: .init(path: "/3/person/1/tv_credits"))

        let credits = try awaitFor { tmdb.people.tvCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
        XCTAssertEqual(credits?.id, 1)
        XCTAssertEqual(credits?.cast.first?.character, "")
    }

    func testReturnsCombinedCredits() throws {
        try stubHelper.stubWithLocalFile(People.combinedCredits(personId: personId, language: nil), expecting: .init(path: "/3/person/1/combined_credits"))

        let credits = try awaitFor { tmdb.people.combinedCredits(for: personId, completion: $0) }.value

        XCTAssertNotNil(credits)
        XCTAssertEqual(credits?.id, 1)
        XCTAssertEqual(credits?.cast.first?.character, "Himself")
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(People.externalIds(personId: personId, language: nil), expecting: .init(path: "/3/person/1/external_ids"))

        let ids = try awaitFor { tmdb.people.externalIds(for: personId, completion: $0) }.value

        XCTAssertNotNil(ids)
        XCTAssertEqual(ids?.id, 1)
        XCTAssertEqual(ids?.imdbId, "nm0000184")
    }

    func testReturnsImages() throws {
        try stubHelper.stubWithLocalFile(People.images(personId: personId), expecting: .init(path: "/3/person/1/images"))

        let images = try awaitFor { tmdb.people.images(for: personId, completion: $0) }.value

        XCTAssertNotNil(images)
        XCTAssertEqual(images?.id, 1)
        XCTAssertEqual(images?.profiles.first?.filePath, "/d8I8oke7Y5K0vlcz6LVCoFHzkxx.jpg")
    }

    func testReturnsTaggedImages() throws {
        try stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil), expecting: .init(path: "/3/person/1/tagged_images", query: ["api_key": "123", "page": "1"]))

        let images = try awaitFor { tmdb.people.taggedImages(for: personId, completion: $0) }.value

        XCTAssertNotNil(images)
        XCTAssertEqual(images?.id, 19)
        XCTAssertEqual(images?.page, 1)
        XCTAssertEqual(images?.totalPages, 1)
        XCTAssertEqual(images?.totalResults, 10)
    }

    func testTaggedImagesResponseParsing() throws {
        try stubHelper.stubWithLocalFile(People.taggedImages(personId: personId, pageNumber: 1, language: nil), expecting: .init(path: "/3/person/1/tagged_images", query: ["api_key": "123", "page": "1"]))

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
        case .episode:
            XCTFail("Expected TV show, received episode")
        }
        XCTAssertEqual(images?.id, 19)
        XCTAssertEqual(images?.page, 1)
        XCTAssertEqual(images?.totalPages, 1)
        XCTAssertEqual(images?.totalResults, 10)
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(People.translations(personId: personId, language: nil), expecting: .init(path: "/3/person/1/translations"))

        let translations = try awaitFor { tmdb.people.translations(for: personId, completion: $0) }.value

        XCTAssertNotNil(translations)
        XCTAssertEqual(translations?.id, 1)
        XCTAssertEqual(translations?.translations.first?.englishName, "cs")
    }

    func testReturnsLatest() throws {
        try stubHelper.stubWithLocalFile(People.latest(language: nil), expecting: .init(path: "/3/person/latest"))

        let person = try awaitFor { tmdb.people.latest(completion: $0) }.value

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.id, 2457919)
        XCTAssertEqual(person?.name, "Ariadny Collucy")
    }

    func testReturnsPopular() throws {
        try stubHelper.stubWithLocalFile(People.popular(pageNumber: 1, language: nil), expecting: .init(path: "/3/person/popular", query: ["api_key": "123", "page": "1"]))

        let person = try awaitFor { tmdb.people.popular(completion: $0) }.value

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.page, 1)
        XCTAssertEqual(person?.totalPages, 500)
        XCTAssertEqual(person?.totalResults, 10000)
        XCTAssertEqual(person?.results.first?.id, 1449329)
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
                       "https://api.themoviedb.org/3/person/1?append_to_response=combined_credits")
        XCTAssertEqual(People.details(personId: personId, language: nil, append: [.recommendations, .credits]).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?append_to_response=combined_credits")
        XCTAssertEqual(People.details(personId: personId, language: "en", append: [.translations, .similar]).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1?language=en&append_to_response=translations")

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
                       "https://api.themoviedb.org/3/person/1/external_ids")

        XCTAssertEqual(People.images(personId: personId).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/images")

        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/tagged_images?page=1")
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 2, language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/tagged_images?page=2")
        XCTAssertEqual(People.taggedImages(personId: personId, pageNumber: 1, language: "en").url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/tagged_images?page=1")

        XCTAssertEqual(People.translations(personId: personId, language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/translations")
        XCTAssertEqual(People.translations(personId: personId, language: "en").url.absoluteString,
                       "https://api.themoviedb.org/3/person/1/translations")

        XCTAssertEqual(People.latest(language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/latest")
        XCTAssertEqual(People.latest(language: "en").url.absoluteString,
                       "https://api.themoviedb.org/3/person/latest")

        XCTAssertEqual(People.popular(pageNumber: 1, language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/popular?page=1")
        XCTAssertEqual(People.popular(pageNumber: 2, language: nil).url.absoluteString,
                       "https://api.themoviedb.org/3/person/popular?page=2")
        XCTAssertEqual(People.popular(pageNumber: 1, language: "en").url.absoluteString,
                       "https://api.themoviedb.org/3/person/popular?page=1&language=en")
    }
}

extension PeopleEndpointTests {
    func testmovieCreditsNondefaultOptions() throws {
        try assertGETQuery("/3/person/1/movie_credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.people.movieCredits(for: 1, language: "fi-FI", completion: $0)
        }
    }

    func testtvCreditsNondefaultOptions() throws {
        try assertGETQuery("/3/person/1/tv_credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.people.tvCredits(for: 1, language: "fi-FI", completion: $0)
        }
    }

    func testcombinedCreditsNondefaultOptions() throws {
        try assertGETQuery("/3/person/1/combined_credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.people.combinedCredits(for: 1, language: "fi-FI", completion: $0)
        }
    }

    func testPopularNondefaultOptions() throws {
        try assertGETQuery("/3/person/popular", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.people.popular(pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }
}
