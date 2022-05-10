//
//  TMDBTestCase.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 10/12/2019.
//

import XCTest
@testable import TMDBKit

class TMDBTestCase: XCTestCase {
    var stubHelper = StubHelper()
    var tmdb: TMDB!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self] + (config.protocolClasses ?? [])
        let urlSession = URLSession(configuration: config)

        let auth = MockAuth()
        let networkClient = NetworkClient(authenticator: auth, urlSession: urlSession)

        tmdb = TMDB(authenticator: auth, networkClient: networkClient)
    }

    override func tearDown() {
        tmdb.clearCaches()
        super.tearDown()
    }
}


final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
