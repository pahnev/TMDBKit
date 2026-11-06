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

    func requestBody(_ request: URLRequest) throws -> Data {
        if let body = request.httpBody { return body }
        let stream = try XCTUnwrap(request.httpBodyStream)
        stream.open()
        defer { stream.close() }
        var body = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            body.append(contentsOf: buffer.prefix(count))
        }
        return body
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
            XCTAssertEqual(request.url?.path, path, file: file, line: line)
            XCTAssertEqual(request.httpMethod, "GET", file: file, line: line)
            XCTAssertNil(request.httpBody, file: file, line: line)
            XCTAssertNil(request.httpBodyStream, file: file, line: line)
            let actual = try self.queryItems(in: request)
            XCTAssertEqual(actual.count, expected.count, file: file, line: line)
            for item in expected {
                XCTAssertEqual(actual.filter { $0 == item }.count,
                               expected.filter { $0 == item }.count, file: file, line: line)
            }
        }
        _ = try awaitFor(invoke)
        XCTAssertEqual(requestCount, 1, file: file, line: line)
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
