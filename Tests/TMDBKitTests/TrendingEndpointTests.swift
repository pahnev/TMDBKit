//
//  TrendingEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 16/11/2019.
//

import XCTest
import Nimble
@testable import TMDBKit

class TrendingEndpointTests: XCTestCase {
    private var stubHelper: StubHelper!
    private var tmdb: TMDB!

    override func setUp() {
        super.setUp()
        self.tmdb = try! TMDB(authenticator: MockAuth())
        self.stubHelper = StubHelper()
    }

    override func tearDown() {
        tmdb.clearCaches()
        super.tearDown()
    }

    func testReturnsTrendingMovies() {
        var response: TrendingResponse?
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .movie, timeWindow: .day))
        tmdb.trending.trending(.movie, withinLast: .day) { result in
            response = result.value
        }
        expect(response).toEventuallyNot(beNil())
    }

    func testReturnsTrendingTVShows() {
        var response: TrendingResponse?
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .tv, timeWindow: .day))
        tmdb.trending.trending(.tv, withinLast: .day) { result in
            response = result.value
        }
        expect(response).toEventuallyNot(beNil())
    }

    func testReturnsTrendingPeople() {
        var response: TrendingResponse?
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .person, timeWindow: .day))

        tmdb.trending.trending(.person, withinLast: .day) { result in
            response = result.value
        }
        expect(response).toEventuallyNot(beNil())
    }

    func testReturnsTrendingEverything() {
        var response: TrendingResponse?
        stubHelper.stubWithLocalFile(Trending.trending(mediaType: .all, timeWindow: .day))
        tmdb.trending.trending(.all, withinLast: .day) { result in
            response = result.value
        }
        expect(response).toEventuallyNot(beNil())
    }

}
