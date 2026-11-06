import XCTest
@testable import TMDBKit

final class NetworkClientTests: TMDBTestCase {
    func testMissingUserSessionRetainsErrorWithoutRequest() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = NetworkClient(authenticator: MockAuth(sessionId: nil), urlSession: URLSession(configuration: config))
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
