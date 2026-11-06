import XCTest
@testable import TMDBKit

final class NetworkClientTests: TMDBTestCase {
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
