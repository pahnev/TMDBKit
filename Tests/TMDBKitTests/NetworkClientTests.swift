import XCTest
@testable import TMDBKit

final class NetworkClientTests: TMDBTestCase {
    func testInjectedCacheRetainsCallerCapacities() {
        let cache = URLCache(memoryCapacity: 1024 * 1024, diskCapacity: 0, diskPath: nil)
        _ = NetworkClient(authenticator: MockAuth(), cache: cache)
        XCTAssertEqual(cache.memoryCapacity, 1024 * 1024)
        XCTAssertEqual(cache.diskCapacity, 0)
    }

    func testMissingUserSessionRetainsErrorWithoutRequest() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = NetworkClient(authenticator: MockAuth(sessionId: nil), urlSession: URLSession(configuration: config), cache: URLCache(memoryCapacity: 1024, diskCapacity: 0, diskPath: nil))
        var requests = 0
        MockURLProtocol.requestHandler = { _ in requests += 1; throw TMDBError.sessionIdMissing }
        var completed = false
        client.executeAuthenticatedRequest(for: Movies.accountStates(movieId: 1), sessionId: nil) { result in
            completed = true
            guard case .error(TMDBError.sessionIdMissing) = result else { return XCTFail("Expected missing-session error") }
        }
        XCTAssertTrue(completed)
        XCTAssertEqual(requests, 0)
    }
}

extension NetworkClientTests {
    func testSharedHTTPErrorMapping() throws {
        for status in [401, 404, 429, 500] {
            tmdb.clearCaches()
            MockURLProtocol.requestHandler = { request in
                try RequestExpectation(path: "/3/authentication/token/new").assertRequest(request)
                return (HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!, Data("{\"status_message\":\"failure\"}".utf8))
            }
            let error = try awaitFor { tmdb.createRequestToken(completion: $0) }.error
            guard case .networkError(let wrapped)? = error, case .httpError(status) = wrapped as? TMDBError else { return XCTFail("Expected HTTP \(status), got \(String(describing: error))") }
        }
    }

    func testSharedNetworkErrorMapping() throws {
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        let error = try awaitFor { tmdb.createRequestToken(completion: $0) }.error
        guard case .networkError(let underlying)? = error else { return XCTFail("Expected network error") }
        guard case .networkError(let transport) = underlying as? TMDBError else { return XCTFail("Expected wrapped transport error") }
        XCTAssertEqual((transport as NSError).code, URLError.timedOut.rawValue)
    }

    func testSharedDecodingErrorMapping() throws {
        stubResponse(["success": "invalid"]) { request in
            try RequestExpectation(path: "/3/authentication/token/new").assertRequest(request)
        }
        let error = try awaitFor { tmdb.createRequestToken(completion: $0) }.error
        guard case .decodingError? = error else { return XCTFail("Expected decoding error") }
    }

    func testSharedNonHTTPResponseMapping() throws {
        MockURLProtocol.requestHandler = { request in
            (URLResponse(url: request.url!, mimeType: "application/json", expectedContentLength: 2, textEncodingName: nil), Data("{}".utf8))
        }
        let error = try awaitFor { tmdb.createRequestToken(completion: $0) }.error
        guard case .networkError(let wrapped)? = error, case .nonHttpResponseError = wrapped as? TMDBError else { return XCTFail("Expected non-HTTP error") }
    }
}


extension NetworkClientTests {
    func testHTTPFailuresCompleteOnce() throws {
        for status in [401, 403, 404, 422, 429, 500] {
            var requests = 0
            MockURLProtocol.requestHandler = { request in
                requests += 1
                return (HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!, Data("{}".utf8))
            }
            let result: Result<RequestToken, TMDBError> = try completionOnce { tmdb.createRequestToken(completion: $0) }
            XCTAssertNil(result.value)
            guard case .httpError(let actual) = underlyingError(try XCTUnwrap(result.error)) as? TMDBError else {
                XCTFail("Expected HTTP \(status), got \(result)")
                continue
            }
            XCTAssertEqual(actual, status)
            XCTAssertEqual(requests, 1)
        }
    }

    func testTransportFailureCompletesOnce() throws {
        var requests = 0
        MockURLProtocol.requestHandler = { _ in requests += 1; throw URLError(.timedOut) }
        let result: Result<RequestToken, TMDBError> = try completionOnce { tmdb.createRequestToken(completion: $0) }
        XCTAssertNil(result.value)
        let error = underlyingError(try XCTUnwrap(result.error)) as NSError
        XCTAssertEqual(error.domain, NSURLErrorDomain)
        XCTAssertEqual(error.code, URLError.timedOut.rawValue)
        XCTAssertEqual(requests, 1)
    }

    func testMalformedJSONReturnsDecodingError() throws {
        var requests = 0
        MockURLProtocol.requestHandler = { request in
            requests += 1
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data("{invalid JSON".utf8))
        }
        let result: Result<RequestToken, TMDBError> = try completionOnce { tmdb.createRequestToken(completion: $0) }
        XCTAssertNil(result.value)
        guard case .decodingError(.dataCorrupted)? = result.error else { return XCTFail("Expected corrupted JSON error") }
        XCTAssertEqual(requests, 1)
    }

    /// Drain already-enqueued main callbacks after fulfillment; no timing sleeps.
    private func completionOnce<T>(_ invoke: (@escaping (T) -> Void) -> Void) throws -> T {
        let completed = expectation(description: "One completion")
        completed.assertForOverFulfill = true
        var count = 0
        var value: T?
        invoke { result in count += 1; value = result; completed.fulfill() }
        wait(for: [completed], timeout: 2)
        let drained = expectation(description: "Main callback queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
        XCTAssertEqual(count, 1)
        return try XCTUnwrap(value)
    }
}

/// The public client intentionally retains its historical nested networkError wrappers.
func underlyingError(_ error: Error) -> Error {
    if case .networkError(let wrapped) = error as? TMDBError { return underlyingError(wrapped) }
    return error
}
