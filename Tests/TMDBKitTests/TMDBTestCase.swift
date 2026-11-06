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

        tmdb = makeTMDB(authenticator: MockAuth(sessionId: "456"), urlSession: urlSession)
    }

    func makeTMDB(authenticator: Authenticator, urlSession: URLSession? = nil) -> TMDB {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = urlSession ?? URLSession(configuration: config)
        let client = NetworkClient(authenticator: authenticator, urlSession: session)
        return TMDB(authenticator: authenticator, networkClient: client)
    }

    func stubResponse(_ response: [String: Any], inspectRequest: @escaping (URLRequest) throws -> Void) {
        MockURLProtocol.requestHandler = { request in
            try inspectRequest(request)
            let data = try JSONSerialization.data(withJSONObject: response)
            return (HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    func queryItems(in request: URLRequest) throws -> [URLQueryItem] {
        let url = try XCTUnwrap(request.url)
        return try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)).queryItems ?? []
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
