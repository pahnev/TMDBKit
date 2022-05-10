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
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .movie, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.movie, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingTVShows() throws {
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .tv, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.tv, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingPeople() throws {
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .person, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.person, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }

    func testReturnsTrendingEverything() throws {
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .all, timeWindow: .day))

        let response = try awaitFor { tmdb.trending.trending(.all, withinLast: .day, completion: $0) }.value

        XCTAssertNotNil(response)
    }
}
