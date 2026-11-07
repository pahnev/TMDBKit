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
    private static let handlerLock = NSRecursiveLock()

    override func setUp() {
        super.setUp()
        Self.handlerLock.lock()
        MockURLProtocol.requestHandler = nil
        stubHelper = StubHelper()

        let config = URLSessionConfiguration.ephemeral
        config.urlCache = URLCache(memoryCapacity: 1024 * 1024, diskCapacity: 0, diskPath: nil)
        config.protocolClasses = [MockURLProtocol.self] + (config.protocolClasses ?? [])
        let urlSession = URLSession(configuration: config)

        tmdb = makeTMDB(authenticator: MockAuth(sessionId: "456"), urlSession: urlSession)
    }

    func makeTMDB(authenticator: Authenticator, urlSession: URLSession? = nil) -> TMDB {
        let config = URLSessionConfiguration.ephemeral
        config.urlCache = URLCache(memoryCapacity: 1024 * 1024, diskCapacity: 0, diskPath: nil)
        config.protocolClasses = [MockURLProtocol.self]
        let session = urlSession ?? URLSession(configuration: config)
        let client = NetworkClient(authenticator: authenticator, urlSession: session, cache: session.configuration.urlCache!)
        return TMDB(authenticator: authenticator, networkClient: client)
    }

    func stubResponse(_ response: [String: Any], inspectRequest: @escaping (URLRequest) throws -> Void) {
        MockURLProtocol.requestHandler = { request in
            try inspectRequest(request)
            let data = try JSONSerialization.data(withJSONObject: response)
            return try (HTTPURLResponse(url: XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    /// Complete pinned standalone example, optionally omitting a standalone-only root ID for nesting.
    func contractObject(_ name: String, omitID: Bool = false) throws -> [String: Any] {
        let root = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let data = try Data(contentsOf: root.appendingPathComponent("Fixtures/Contract/\(name).json"))
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        if omitID {
            object.removeValue(forKey: "id")
        }
        return object
    }

    func requestBody(_ request: URLRequest) throws -> Data {
        try requestBodyData(request)
    }

    func queryItems(in request: URLRequest) throws -> [URLQueryItem] {
        let url = try XCTUnwrap(request.url)
        return try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)).queryItems ?? []
    }

    /// Wire-only checks deliberately ignore decoding: response-model contracts are tested separately.
    func assertGETQuery<T>(_ path: String, _ expected: [URLQueryItem],
                           file: StaticString = #file, line: UInt = #line,
                           invoke: (@escaping TMDBResult<T>) -> Void) throws {
        tmdb.clearCaches()
        var requestCount = 0
        stubResponse([:]) { request in
            requestCount += 1
            let query = expected.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
            try RequestExpectation(path: path, query: query).assertRequest(request, file: file, line: line)
        }
        _ = try awaitFor(invoke)
        XCTAssertEqual(requestCount, 1, file: file, line: line)
    }

    override func tearDown() {
        stubHelper.verifyRequests()
        MockURLProtocol.requestHandler = nil
        tmdb.clearCaches()
        tmdb = nil
        Self.handlerLock.unlock()
        super.tearDown()
    }
}

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

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
