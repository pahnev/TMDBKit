//
//  TMDBTestCase.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 10/12/2019.
//

@testable import TMDBKit
import XCTest

class TMDBTestCase: XCTestCase {
    var stubHelper = StubHelper()
    var tmdb: TMDB!

    override func setUp() {
        guard let tmdb = try? TMDB(authenticator: MockAuth()) else { preconditionFailure() }
        self.tmdb = tmdb
        super.setUp()
    }

    override func tearDown() {
        tmdb.clearCaches()
        super.tearDown()
    }
}
