//
//  TrendingEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import XCTest
@testable import TMDBKit

class TrendingEndpointTests: TMDBTestCase {
    func testTrendingLanguageQuery() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        for media: MediaType in [.all, .movie, .tv, .person] {
            for window: TimeWindow in [.day, .week] {
                let path = "/3/trending/\(media.rawValue)/\(window.rawValue)"
                try assertGETQuery(path, application) { tmdb.trending.trending(media, withinLast: window, completion: $0) }
                try assertGETQuery(path, application) { tmdb.trending.trending(media, withinLast: window, language: nil, completion: $0) }
                try assertGETQuery(path, application + [URLQueryItem(name: "language", value: "fi-FI")]) {
                    tmdb.trending.trending(media, withinLast: window, language: "fi-FI", completion: $0)
                }
            }
        }
    }

    func testReturnsTrendingMovies() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .movie, timeWindow: .day), expecting: .init(path: "/3/trending/movie/day"))

        let response = try awaitFor { tmdb.trending.trending(.movie, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.page, 1)
        XCTAssertEqual(response?.totalPages, 1000)
        XCTAssertEqual(response?.totalResults, 20000)
        guard case .movie(let movie)? = response?.results.first else { return XCTFail("Expected movie") }
        XCTAssertEqual(movie.id, 423204)
    }

    func testReturnsTrendingTVShows() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .tv, timeWindow: .day), expecting: .init(path: "/3/trending/tv/day"))

        let response = try awaitFor { tmdb.trending.trending(.tv, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.page, 1)
        XCTAssertEqual(response?.totalPages, 1000)
        XCTAssertEqual(response?.totalResults, 20000)
        guard case .tv(let tv)? = response?.results.first else { return XCTFail("Expected TV") }
        XCTAssertEqual(tv.id, 82856)
    }

    func testReturnsTrendingPeople() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .person, timeWindow: .day), expecting: .init(path: "/3/trending/person/day"))

        let response = try awaitFor { tmdb.trending.trending(.person, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.page, 1)
        XCTAssertEqual(response?.totalPages, 1000)
        XCTAssertEqual(response?.totalResults, 20000)
        guard case .person(let person)? = response?.results.first else { return XCTFail("Expected person") }
        XCTAssertEqual(person.id, 1277188)
    }

    func testReturnsTrendingEverything() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .all, timeWindow: .day), expecting: .init(path: "/3/trending/all/day"))

        let response = try awaitFor { tmdb.trending.trending(.all, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.page, 1)
        XCTAssertEqual(response?.totalPages, 1000)
        XCTAssertEqual(response?.totalResults, 20000)
        guard case .tv(let tv)? = response?.results.first else { return XCTFail("Expected TV") }
        XCTAssertEqual(tv.id, 82856)
    }

    func test_httpMethod() {
        XCTAssertEqual(Trending.trending(mediaType: .all, timeWindow: .day).httpMethod, .GET)
    }

    func test_httpBody() {
        XCTAssertNil(Trending.trending(mediaType: .all, timeWindow: .day).httpBody)
    }

    func test_requestHeaders() {
        XCTAssertEqual(Trending.trending(mediaType: .all, timeWindow: .day).requestHeaders, [:])
    }

    func test_urlConstruction() {
        XCTAssertEqual(Trending.trending(mediaType: .all, timeWindow: .day).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/all/day")
        XCTAssertEqual(Trending.trending(mediaType: .movie, timeWindow: .day).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/movie/day")
        XCTAssertEqual(Trending.trending(mediaType: .tv, timeWindow: .day).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/tv/day")
        XCTAssertEqual(Trending.trending(mediaType: .person, timeWindow: .day).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/person/day")

        XCTAssertEqual(Trending.trending(mediaType: .all, timeWindow: .week).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/all/week")
        XCTAssertEqual(Trending.trending(mediaType: .movie, timeWindow: .week).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/movie/week")
        XCTAssertEqual(Trending.trending(mediaType: .tv, timeWindow: .week).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/tv/week")
        XCTAssertEqual(Trending.trending(mediaType: .person, timeWindow: .week).url.absoluteString,
                       "https://api.themoviedb.org/3/trending/person/week")
    }
}

extension TrendingEndpointTests {
    func testWeeklyTrendingAllRequestAndResponse() throws {
        stubResponse(try contractObject("trending-all")) { request in
            try RequestExpectation(path: "/3/trending/all/week", query: ["api_key": "123", "language": "fi-FI"]).assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.trending.trending(.all, withinLast: .week, language: "fi-FI", completion: $0) }.value)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 1000)
        XCTAssertEqual(response.totalResults, 20000)
        guard case .movie(let movie)? = response.results.first else { return XCTFail("Expected movie") }
        XCTAssertEqual(movie.title, "Scream VI")
    }

    func testWeeklyTrendingMovieRequestAndResponse() throws {
        // Reuse a movie response fixture; its selection is independent of the asserted week route.
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .movie, timeWindow: .day), expecting: .init(path: "/3/trending/movie/week", query: ["api_key": "123", "language": "fi-FI"]))
        let response = try XCTUnwrap(awaitFor { tmdb.trending.trending(.movie, withinLast: .week, language: "fi-FI", completion: $0) }.value)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 1000)
        XCTAssertEqual(response.totalResults, 20000)
        guard case .movie(let movie)? = response.results.first else { return XCTFail("Expected movie") }
        XCTAssertEqual(movie.id, 423204)
        XCTAssertEqual(movie.title, "Angel Has Fallen")
    }

    func testWeeklyTrendingTVRequestAndResponse() throws {
        stubResponse(try contractObject("trending-tv")) { request in
            try RequestExpectation(path: "/3/trending/tv/week", query: ["api_key": "123", "language": "fi-FI"]).assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.trending.trending(.tv, withinLast: .week, language: "fi-FI", completion: $0) }.value)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 1000)
        XCTAssertEqual(response.totalResults, 20000)
        guard case .tv(let tv)? = response.results.first else { return XCTFail("Expected TV") }
        XCTAssertEqual(tv.name, "Sweet Tooth")
    }

    func testWeeklyTrendingPeopleRequestAndResponse() throws {
        stubResponse(try contractObject("trending-people")) { request in
            try RequestExpectation(path: "/3/trending/person/week", query: ["api_key": "123", "language": "fi-FI"]).assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.trending.trending(.person, withinLast: .week, language: "fi-FI", completion: $0) }.value)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 1000)
        XCTAssertEqual(response.totalResults, 20000)
        guard case .person(let person)? = response.results.first else { return XCTFail("Expected person") }
        XCTAssertEqual(person.name, "Ana de Armas")
    }
}
