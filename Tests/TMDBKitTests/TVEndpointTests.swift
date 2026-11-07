//
//  TVEndpointTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 01/12/2019.
//

import CoreFoundation
import XCTest
@testable import TMDBKit

class TVEndpointTests: TMDBTestCase {
    func testTVAllSupportedAppendsDecode() throws {
        var object = try contractObject("tv-series-details")
        for resource in ["credits", "reviews", "videos", "images", "similar", "translations"] {
            let omitID = ["credits", "reviews", "videos", "images", "translations"].contains(resource)
            object[resource] = try contractObject("tv-series-" + resource, omitID: omitID)
        }
        object["recommendations"] = try contractObject("tv-recommendations")
        stubResponse(object) { request in
            XCTAssertEqual(request.url?.path, "/3/tv/1399")
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(try self.queryItems(in: request).filter { $0.name == "append_to_response" }.first?.value, "images,reviews,videos,credits,similar,recommendations,translations")
        }
        let tv = try XCTUnwrap(awaitFor { tmdb.tv.details(for: 1399, appending: DetailsAppendable.allCases, completion: $0) }.value)
        XCTAssertEqual(tv.credits?.cast.first?.character, "Tyrion Lannister")
        XCTAssertEqual(tv.credits?.crew.first?.name, "Duncan Muggoch")
        XCTAssertEqual(tv.similar?.results.first?.id, 197063)
        XCTAssertEqual(tv.recommendations?.results.first?.id, 1396)
        XCTAssertEqual(tv.translations?.translations.first?.data.tagline, "الشتاء قادم")
        XCTAssertEqual(tv.images?.posters.first?.filePath, "/r3pPehX4ik8NLYPpbDRAh0YRtMb.jpg")
        XCTAssertEqual(tv.reviews?.results.first?.author, "lmao7")
        XCTAssertEqual(tv.videos?.results.first?.key, "y2ZJ3lTaREY")
    }

    func testGuestAccountStatesAndRatingsUseGuestSessionOnly() throws {
        try checkSession(guest: "guest", expectedKey: "guest_session_id", expectedValue: "guest")
        tmdb = makeTMDB(authenticator: MockAuth(sessionId: nil))
        try checkSession(guest: "guest", expectedKey: "guest_session_id", expectedValue: "guest")
    }

    func testDefaultUserSessionRemainsCompatible() throws {
        try checkSession(guest: nil, expectedKey: "session_id", expectedValue: "456")
    }

    private func checkSession(guest: String?, expectedKey: String, expectedValue: String) throws {
        let credentials = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: expectedKey, value: expectedValue)]
        stubResponse(["id": 1, "favorite": true, "watchlist": false, "rated": ["value": 8.5]]) { request in
            try RequestExpectation(path: "/3/tv/1/account_states", query: ["api_key": "123", expectedKey: expectedValue]).assertRequest(request)
        }
        let state = try XCTUnwrap(awaitFor { tmdb.tv.accountStates(for: 1, guestSessionId: guest, completion: $0) }.value)
        XCTAssertEqual(state.id, 1)
        XCTAssertTrue(state.favorite)
        XCTAssertEqual(state.rated?.value, 8.5)
        for method in ["POST", "DELETE"] {
            var count = 0
            stubResponse(["status_code": 1, "status_message": "ok"]) { request in
                count += 1
                XCTAssertEqual(request.httpMethod, method)
                XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
                XCTAssertEqual(request.url?.path, "/3/tv/1/rating")
                XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json;charset=utf-8")
                let query = try self.queryItems(in: request)
                XCTAssertEqual(query.count, 2)
                for item in credentials {
                    XCTAssertEqual(query.filter { $0 == item }.count, 1)
                }
                if method == "POST" {
                    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: self.requestBody(request)) as? [String: Double])
                    XCTAssertEqual(object, ["value": 8.5])
                } else {
                    XCTAssertNil(request.httpBody)
                    XCTAssertNil(request.httpBodyStream)
                }
            }
            let response: StatusResponse?
            if method == "POST" {
                response = try awaitFor { tmdb.tv.rateShow(1, rating: 8.5, guestSessionId: guest, completion: $0) }.value
            } else {
                response = try awaitFor { tmdb.tv.deleteRating(of: 1, guestSessionId: guest, completion: $0) }.value
            }
            XCTAssertEqual(response?.statusCode, 1)
            XCTAssertEqual(response?.statusMessage, "ok")
            XCTAssertEqual(count, 1)
        }
    }

    private let gameOfThrones = 1399

    func testTVVideoLanguageFallbackQuery() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/tv/1/videos", application) { tmdb.tv.videos(for: 1, completion: $0) }
        try assertGETQuery("/3/tv/1/videos", application) { tmdb.tv.videos(for: 1, includeVideoLanguages: nil, completion: $0) }
        try assertGETQuery("/3/tv/1/videos", application + [URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "include_video_language", value: "fi,en")]) {
            tmdb.tv.videos(for: 1, language: "fi-FI", includeVideoLanguages: ["fi", "en"], completion: $0)
        }
    }

    func testTVListTimezoneQuery() throws {
        let paged = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2")]
        let options = [URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "timezone", value: "Europe/Helsinki")]
        try assertGETQuery("/3/tv/airing_today", paged) { tmdb.tv.airingToday(pageNumber: 2, completion: $0) }
        try assertGETQuery("/3/tv/airing_today", paged) { tmdb.tv.airingToday(pageNumber: 2, timezone: nil, completion: $0) }
        try assertGETQuery("/3/tv/airing_today", paged + options) {
            tmdb.tv.airingToday(pageNumber: 2, language: "fi-FI", timezone: "Europe/Helsinki", completion: $0)
        }
        try assertGETQuery("/3/tv/on_the_air", paged) { tmdb.tv.onTheAir(pageNumber: 2, completion: $0) }
        try assertGETQuery("/3/tv/on_the_air", paged) { tmdb.tv.onTheAir(pageNumber: 2, timezone: nil, completion: $0) }
        try assertGETQuery("/3/tv/on_the_air", paged + options) {
            tmdb.tv.onTheAir(pageNumber: 2, language: "fi-FI", timezone: "Europe/Helsinki", completion: $0)
        }
    }

    func testImageLanguageFallbackQuery() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/tv/1/images", application) { tmdb.tv.images(for: 1, completion: $0) }
        try assertGETQuery("/3/tv/1/images", application) { tmdb.tv.images(for: 1, includeImageLanguages: nil, completion: $0) }
        try assertGETQuery("/3/tv/1/images", application + [URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "include_image_language", value: "en,null")]) {
            tmdb.tv.images(for: 1, language: "fi-FI", includeImageLanguages: ["en", "null"], completion: $0)
        }
        try assertGETQuery("/3/tv/1/images", application + [URLQueryItem(name: "include_image_language", value: "")]) {
            tmdb.tv.images(for: 1, includeImageLanguages: [], completion: $0)
        }
    }

    func testLegacyUndocumentedQueriesAreOmitted() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/tv/1/account_states", application + [URLQueryItem(name: "session_id", value: "456")]) {
            tmdb.tv.accountStates(for: 1, language: "fi-FI", completion: $0)
        }
        try assertGETQuery("/3/tv/1/alternative_titles", application) { tmdb.tv.alternativeTitles(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/tv/1/content_ratings", application) { tmdb.tv.contentRatings(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/tv/1/episode_groups", application) { tmdb.tv.episodeGroups(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/tv/1/external_ids", application) { tmdb.tv.externalIds(for: 1, language: "fi-FI", completion: $0) }
        try assertGETQuery("/3/tv/latest", application) { tmdb.tv.latest(in: "fi-FI", completion: $0) }
    }

    func testChangesForwardsDateRangeAndPage() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/3/tv/1399/changes")
            let items = try self.queryItems(in: request)
            for (name, value) in [("page", "2"), ("start_date", "2026-11-01"), ("end_date", "2026-11-06")] {
                XCTAssertEqual(items.filter { $0.name == name }.map { $0.value }, [value])
            }
        }
        let result = try awaitFor {
            tmdb.tv.changes(for: 1399, pageNumber: 2, startDate: "2026-11-01", endDate: "2026-11-06", completion: $0)
        }.value
        XCTAssertNotNil(result)
        XCTAssertEqual(requestCount, 1)
    }

    func testChangesOmitsUnspecifiedDates() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/tv/1399/changes")
            let items = try self.queryItems(in: request)
            XCTAssertEqual(items.filter { $0.name == "page" }.map { $0.value }, ["1"])
            XCTAssertFalse(items.contains { $0.name == "start_date" || $0.name == "end_date" })
        }
        XCTAssertNotNil(try awaitFor { tmdb.tv.changes(for: 1399, completion: $0) }.value)
        XCTAssertEqual(requestCount, 1)
    }

    func testReturnsDetails() throws {
        try stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, language: nil, append: nil), expecting: .init(path: "/3/tv/1399"))

        let result = try awaitFor { tmdb.tv.details(for: gameOfThrones, appending: nil, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.name, "Game of Thrones")
    }

    func testReturnsDetailsWithAppendedData() throws {
        try stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, language: nil, append: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)]), expecting: .init(path: "/3/tv/1399", query: ["api_key": "123", "append_to_response": "reviews,videos,images"]))

        let result = try awaitFor {
            tmdb.tv.details(for: gameOfThrones,
                            appending: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)],
                            completion: $0)
        }.value

        XCTAssertNotNil(result?.reviews)
        XCTAssertNotNil(result?.videos)
        XCTAssertNotNil(result?.images)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.name, "Game of Thrones")
    }

    func testDetailsURL() {
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
        XCTAssertEqual(appendingEverything.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=reviews,images,videos&language=en&include_image_language=en,es")
    }

    func test_accountStates() throws {
        try stubHelper.stubWithLocalFile(TV.accountStates(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/account_states", query: ["api_key": "123", "session_id": "456"]))

        let result = try awaitFor { tmdb.tv.accountStates(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
    }

    func testTVAccountStatesSendsConfiguredSession() throws {
        var requestCount = 0
        stubResponse(["id": 1399, "favorite": false, "rated": false, "watchlist": true]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/tv/1399/account_states")
            let items = try self.queryItems(in: request)
            XCTAssertEqual(items.filter { $0.name == "session_id" }.map { $0.value }, ["456"])
        }
        let state = try awaitFor { tmdb.tv.accountStates(for: 1399, completion: $0) }.value
        XCTAssertEqual(state?.id, 1399)
        XCTAssertEqual(state?.watchlist, true)
        XCTAssertEqual(requestCount, 1)
    }

    func testTVAccountStatesWithoutSessionDoesNotRequest() throws {
        let service = makeTMDB(authenticator: MockAuth())
        var requestCount = 0
        stubResponse(["id": 1399, "favorite": false, "rated": false, "watchlist": false]) { _ in
            requestCount += 1
        }
        var completionCount = 0
        let result = try awaitFor { completion in
            service.tv.accountStates(for: 1399) {
                completionCount += 1
                completion($0)
            }
        }
        switch result.error {
        case .sessionIdMissing?: break
        case .networkError(let error)?:
            guard case TMDBError.sessionIdMissing = error else {
                return XCTFail("Expected missing session, got \(error)")
            }
        default: XCTFail("Expected missing session, got \(String(describing: result.error))")
        }
        XCTAssertEqual(requestCount, 0)
        XCTAssertEqual(completionCount, 1)
    }

    func test_aggregateCredits() throws {
        try stubHelper.stubWithLocalFile(TV.aggregateCredits(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/aggregate_credits"))

        let result = try awaitFor { tmdb.tv.aggregateCredits(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.cast.first?.name, "Emilia Clarke")
    }

    func testReturnsAlternativeTitles() throws {
        try stubHelper.stubWithLocalFile(TV.alternativeTitles(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/alternative_titles"))

        let result = try awaitFor { tmdb.tv.alternativeTitles(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.results.first?.title, "Game Of Thrones")
    }

    func testReturnsChanges() throws {
        try stubHelper.stubWithLocalFile(TV.changes(tvId: gameOfThrones, pageNumber: 1), expecting: .init(path: "/3/tv/1399/changes", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.changes(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.changes?.first?.key, "season")
    }

    func testReturnsContentRatings() throws {
        try stubHelper.stubWithLocalFile(TV.contentRatings(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/content_ratings"))

        let result = try awaitFor { tmdb.tv.contentRatings(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.results.first?.rating, "16")
    }

    func testReturnsCredits() throws {
        try stubHelper.stubWithLocalFile(TV.credits(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/credits"))

        let result = try awaitFor { tmdb.tv.credits(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.cast.first?.name, "Peter Dinklage")
    }

    func testReturnsEpisodeGroups() throws {
        try stubHelper.stubWithLocalFile(TV.episodeGroups(tvId: 30983, language: nil), expecting: .init(path: "/3/tv/30983/episode_groups"))

        let result = try awaitFor { tmdb.tv.episodeGroups(for: 30983, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 30983)
        XCTAssertEqual(result?.results?.first?.name, "Year Split")
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(TV.externalIds(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/external_ids"))

        let result = try awaitFor { tmdb.tv.externalIds(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.imdbId, "tt0944947")
    }

    func testReturnsImages() throws {
        try stubHelper.stubWithLocalFile(TV.images(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/images"))

        let result = try awaitFor { tmdb.tv.images(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.backdrops.first?.filePath, "/suopoADq0k8YZr4dQXcU6pToj6s.jpg")
    }

    func testReturnsKeywords() throws {
        try stubHelper.stubWithLocalFile(TV.keywords(tvId: gameOfThrones), expecting: .init(path: "/3/tv/1399/keywords"))

        let result = try awaitFor { tmdb.tv.keywords(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.results.first?.name, "war")
    }

    func testReturnsRecommendations() throws {
        try stubHelper.stubWithLocalFile(TV.recommendations(tvId: gameOfThrones, pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/1399/recommendations", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.recommendations(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 2)
        XCTAssertEqual(result?.totalResults, 40)
        XCTAssertEqual(result?.results.first?.id, 1396)
    }

    func testReturnsReviews() throws {
        try stubHelper.stubWithLocalFile(TV.reviews(tvId: gameOfThrones, pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/1399/reviews", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.reviews(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 1)
        XCTAssertEqual(result?.totalResults, 9)
        XCTAssertEqual(result?.results.first?.id, "58aa82f09251416f92006a3a")
    }

    func testReturnsScreenedTheatrically() throws {
        try stubHelper.stubWithLocalFile(TV.screenedTheatrically(tvId: gameOfThrones), expecting: .init(path: "/3/tv/1399/screened_theatrically"))

        let result = try awaitFor { tmdb.tv.screenedTheatrically(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.results.first?.episodeNumber, 9)
    }

    func testReturnsSimilarShows() throws {
        try stubHelper.stubWithLocalFile(TV.similarShows(tvId: gameOfThrones, pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/1399/similar", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.similarShows(for: gameOfThrones, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 43)
        XCTAssertEqual(result?.totalResults, 848)
        XCTAssertEqual(result?.results.first?.id, 95133)
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(TV.translations(tvId: gameOfThrones), expecting: .init(path: "/3/tv/1399/translations"))

        let result = try awaitFor { tmdb.tv.translations(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.translations.first?.englishName, "Arabic")
    }

    func testReturnsVideos() throws {
        try stubHelper.stubWithLocalFile(TV.videos(tvId: gameOfThrones, language: nil), expecting: .init(path: "/3/tv/1399/videos"))

        let result = try awaitFor { tmdb.tv.videos(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
        XCTAssertEqual(result?.results.first?.key, "bjqEWgDVPe0")
    }

    func testReturnsLatestShows() throws {
        try stubHelper.stubWithLocalFile(TV.latest(language: nil), expecting: .init(path: "/3/tv/latest"))

        let result = try awaitFor { tmdb.tv.latest(completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 95589)
        XCTAssertEqual(result?.name, "我爱男闺蜜")
    }

    func testReturnsAiringToday() throws {
        try stubHelper.stubWithLocalFile(TV.airingToday(pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/airing_today", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.airingToday(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 10)
        XCTAssertEqual(result?.totalResults, 188)
        XCTAssertEqual(result?.results.first?.id, 1412)
    }

    func testReturnsOnAirShows() throws {
        try stubHelper.stubWithLocalFile(TV.onTheAir(pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/on_the_air", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.onTheAir(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 26)
        XCTAssertEqual(result?.totalResults, 513)
        XCTAssertEqual(result?.results.first?.id, 60625)
    }

    func testReturnsPopular() throws {
        try stubHelper.stubWithLocalFile(TV.popular(pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/popular", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.popular(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 500)
        XCTAssertEqual(result?.totalResults, 10000)
        XCTAssertEqual(result?.results.first?.id, 60625)
    }

    func testReturnsTopRated() throws {
        try stubHelper.stubWithLocalFile(TV.topRated(pageNumber: 1, language: nil), expecting: .init(path: "/3/tv/top_rated", query: ["api_key": "123", "page": "1"]))

        let result = try awaitFor { tmdb.tv.topRated(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.totalPages, 33)
        XCTAssertEqual(result?.totalResults, 655)
        XCTAssertEqual(result?.results.first?.id, 100)
    }

    func test_watchProviders() throws {
        try stubHelper.stubWithLocalFile(TV.watchProviders(tvId: gameOfThrones), expecting: .init(path: "/3/tv/1399/watch/providers"))

        let result = try awaitFor { tmdb.tv.watchProviders(for: gameOfThrones, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1399)
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
        let data = try XCTUnwrap(TV.rateShow(tvId: 1399, rating: 8.5).httpBody)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Double])
        XCTAssertEqual(body, ["value": 8.5])
        XCTAssertEqual(TV.rateShow(tvId: 1399, rating: 8.5).url.path, "/3/tv/1399/rating")
    }

    func testRateShowSerializesBoundaryRatings() throws {
        for rating in [0.5, 10.0] {
            let data = try XCTUnwrap(TV.rateShow(tvId: 1399, rating: rating).httpBody)
            let body = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
            XCTAssertEqual(Set(body.keys), Set(["value"]))
            let number = try XCTUnwrap(body["value"] as? NSNumber)
            XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
            XCTAssertEqual(number.doubleValue, rating)
        }
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
        XCTAssertEqual(TV.details(tvId: 1, language: "en", append: [.reviews(language: "en"), .videos(language: nil), .images(languages: nil)]).url, URL(string: "https://api.themoviedb.org/3/tv/1?language=en&append_to_response=reviews,videos,images"))

        XCTAssertEqual(TV.accountStates(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/account_states"))
        XCTAssertEqual(TV.accountStates(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/account_states"))

        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/aggregate_credits"))
        XCTAssertEqual(TV.aggregateCredits(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/aggregate_credits?language=en"))

        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/alternative_titles"))
        XCTAssertEqual(TV.alternativeTitles(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/alternative_titles"))

        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/changes?page=1"))
        XCTAssertEqual(TV.changes(tvId: 1, pageNumber: 1).url, URL(string: "https://api.themoviedb.org/3/tv/1/changes?page=1"))

        XCTAssertEqual(TV.contentRatings(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/content_ratings"))
        XCTAssertEqual(TV.contentRatings(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/content_ratings"))

        XCTAssertEqual(TV.credits(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/credits"))
        XCTAssertEqual(TV.credits(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/credits?language=en"))

        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/episode_groups"))
        XCTAssertEqual(TV.episodeGroups(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/episode_groups"))

        XCTAssertEqual(TV.externalIds(tvId: 1, language: nil).url, URL(string: "https://api.themoviedb.org/3/tv/1/external_ids"))
        XCTAssertEqual(TV.externalIds(tvId: 1, language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/1/external_ids"))

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
        XCTAssertEqual(TV.latest(language: "en").url, URL(string: "https://api.themoviedb.org/3/tv/latest"))

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

extension TVEndpointTests {
    func testAppendQueriesPreserveLanguageAndPage() throws {
        var object = try contractObject("tv-series-details")
        var reviews = try contractObject("tv-series-reviews", omitID: true)
        reviews["page"] = 2
        reviews["total_pages"] = 4
        reviews["total_results"] = 61
        object["reviews"] = reviews
        stubResponse(object) { request in
            try RequestExpectation(path: "/3/tv/1399", query: ["api_key": "123", "language": "fi-FI", "append_to_response": "reviews,videos,images", "include_image_language": "fi,en,null"]).assertRequest(request)
        }
        let tv = try XCTUnwrap(awaitFor { tmdb.tv.details(for: 1399, language: "fi-FI", appending: [.reviews(language: "es"), .videos(language: "en"), .images(languages: ["fi", "en", "null"])], completion: $0) }.value)
        XCTAssertEqual(tv.id, 1399)
        XCTAssertEqual(tv.reviews?.page, 2)
        XCTAssertEqual(tv.reviews?.totalPages, 4)
        XCTAssertEqual(tv.reviews?.totalResults, 61)
        XCTAssertEqual(tv.reviews?.results.first?.author, "lmao7")
    }
}

extension TVEndpointTests {
    func testrecommendationsNondefaultOptions() throws {
        try assertGETQuery("/3/tv/1399/recommendations", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.recommendations(for: 1399, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testsimilarShowsNondefaultOptions() throws {
        try assertGETQuery("/3/tv/1399/similar", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.similarShows(for: 1399, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testreviewsNondefaultOptions() throws {
        try assertGETQuery("/3/tv/1399/reviews", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.reviews(for: 1399, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testpopularNondefaultOptions() throws {
        try assertGETQuery("/3/tv/popular", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.popular(pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testtopRatedNondefaultOptions() throws {
        try assertGETQuery("/3/tv/top_rated", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.topRated(pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testaggregateCreditsNondefaultOptions() throws {
        try assertGETQuery("/3/tv/1399/aggregate_credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.aggregateCredits(for: 1399, language: "fi-FI", completion: $0)
        }
    }

    func testcreditsNondefaultOptions() throws {
        try assertGETQuery("/3/tv/1399/credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.tv.credits(for: 1399, language: "fi-FI", completion: $0)
        }
    }
}

extension TVEndpointTests {
    func testOriginalRatingOverloadsReturnStatus() throws {
        let rate = tmdb.tv.rateShow(_:rating:completion:)
        let delete = tmdb.tv.deleteRating(of:completion:)
        stubResponse(["status_code": 1, "status_message": "Created."]) { request in
            try RequestExpectation(path: "/3/tv/1/rating", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["value": 8.5], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let rated = try XCTUnwrap(awaitFor { rate(1, 8.5, $0) }.value)
        XCTAssertEqual(rated.statusCode, 1)
        XCTAssertEqual(rated.statusMessage, "Created.")
        stubResponse(["status_code": 13, "status_message": "Deleted."]) { request in
            try RequestExpectation(path: "/3/tv/1/rating", method: "DELETE", query: ["api_key": "123", "session_id": "456"], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let deleted = try XCTUnwrap(awaitFor { delete(1, $0) }.value)
        XCTAssertEqual(deleted.statusCode, 13)
        XCTAssertEqual(deleted.statusMessage, "Deleted.")
    }
}
