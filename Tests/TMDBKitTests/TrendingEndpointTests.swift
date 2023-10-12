//
//  TrendingEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import XCTest
@testable import TMDBKit

class TrendingEndpointTests: TMDBTestCase {
    func testReturnsTrendingMovies() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .movie, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.movie, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingTVShows() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .tv, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.tv, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingPeople() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .person, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.person, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingEverything() throws {
        try stubHelper.stubWithLocalFile(Trending.trending(mediaType: .all, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.all, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
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
