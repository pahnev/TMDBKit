//
//  DiscoverEndpointTests.swift
//  TMDBKitTests
//
//  Created by Pahnev, Kirill on 8.3.2022.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Nimble
@testable import TMDBKit
import XCTest

class DiscoverEndpointTests: TMDBTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_propertiesConvertToQuery() {
        let filter = DiscoveryFilter.region("FI")
//        let queryItems = filter.convertToURLQuery()
//        XCTAssertEqual(queryItems.count, 2)
//        print(queryItems)
    }

    // MARK: - Movies
    
    func test_movies_without_parameters() throws {
        let movies = try awaitFor { tmdb.discover.movies(completion: $0) }.value
        expect(movies).toEventuallyNot(beNil())
    }

    func test_movies_filteredBy_year() throws {
        let movies = try awaitFor { tmdb.discover.movies(filteringBy: [.year(2000), .region("FI")], completion: $0) }.value
        expect(movies).toEventuallyNot(beNil())
    }

    // MARK: - TVShows

    func test_tvShows_without_parameters() throws {
        let tvShows = try awaitFor { tmdb.discover.tvShows(completion: $0) }.value
        expect(tvShows).toEventuallyNot(beNil())
    }
}
