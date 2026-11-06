//
//  AuthenticationEndpointTests.swift
//
//
//  Created by Kirill Pahnev on 11.10.2023.
//

import XCTest
@testable import TMDBKit

final class AuthenticationEndpointTests: TMDBTestCase {
    func testDeleteSessionUsesBodyWithoutSessionQuery() throws {
        var requestCount = 0
        stubResponse(["success": true]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/authentication/session")
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json;charset=utf-8")
            XCTAssertEqual(try self.queryItems(in: request), [URLQueryItem(name: "api_key", value: "123")])
            let body = try XCTUnwrap(requestBodyJSON(request) as? [String: String])
            XCTAssertEqual(body, ["session_id": "456"])
        }
        XCTAssertEqual(try awaitFor { tmdb.deleteSession(completion: $0) }.value?.success, true)
        XCTAssertEqual(requestCount, 1)
    }

    func test_createRequestToken_returnsToken() throws {
        try stubHelper.stubWithLocalFile(Authentication.requestToken, expecting: .init(path: "/3/authentication/token/new"))

        let token = try awaitFor { tmdb.createRequestToken(completion: $0) }.value

        XCTAssertNotNil(token)
        XCTAssertEqual(token?.requestToken, "7651df58ba8c997583f7e895a18de6b66130edba")
    }

    func test_createSession_returnsSession() throws {
        try stubHelper.stubWithLocalFile(Authentication.createSession(requestToken: "123"), expecting: .init(path: "/3/authentication/session/new", method: "POST", body: ["request_token": "123"], contentType: "application/json;charset=utf-8"))
        let requestToken = RequestToken(success: true, expiresAt: "now", requestToken: "123")
        let token = try awaitFor { tmdb.createSession(requestToken: requestToken, completion: $0) }.value

        XCTAssertNotNil(token)
        XCTAssertEqual(token?.sessionId, "79191836ddaa0da3df76a5ffef6f07ad6ab0c641")
    }

    func testUpdatedAuthenticatorIsUsedByTransport() throws {
        struct Credentials: Authenticator {
            let apiKey: String
            let sessionId: String?
        }
        let service = makeTMDB(authenticator: Credentials(apiKey: "key-A", sessionId: "session-A"))
        service.updateAuthenticator(Credentials(apiKey: "key-B", sessionId: "session-B"))
        var requestCount = 0
        stubResponse(["id": 1399, "favorite": false, "rated": false, "watchlist": false]) { request in
            requestCount += 1
            let items = try self.queryItems(in: request)
            XCTAssertEqual(items.filter { $0.name == "api_key" }.map { $0.value }, ["key-B"])
            XCTAssertEqual(items.filter { $0.name == "session_id" }.map { $0.value }, ["session-B"])
            XCTAssertFalse(items.contains { $0.value == "key-A" || $0.value == "session-A" })
        }
        XCTAssertNotNil(try awaitFor { service.tv.accountStates(for: 1399, completion: $0) }.value)
        XCTAssertEqual(requestCount, 1)
    }

    func testCreateSessionTokenOnlyInJSONBody() throws {
        var requestCount = 0
        stubResponse(["success": true, "session_id": "new-session"]) { request in
            requestCount += 1
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/3/authentication/session/new")
            XCTAssertFalse(try self.queryItems(in: request).contains { $0.name == "request_token" })
            let body = try XCTUnwrap(requestBodyJSON(request) as? [String: String])
            XCTAssertEqual(body, ["request_token": "token-123"])
        }
        let token = RequestToken(success: true, expiresAt: "now", requestToken: "token-123")
        let session = try awaitFor { tmdb.createSession(requestToken: token, completion: $0) }.value
        XCTAssertEqual(session?.sessionId, "new-session")
        XCTAssertEqual(requestCount, 1)
    }

    func test_deleteSession_withoutSession_returnsError() throws {
        let tmdb = TMDB(authenticator: MockAuth())
        let error = try awaitFor { tmdb.deleteSession(completion: $0) }.error

        guard case .sessionIdMissing = error else {
            XCTFail("Expected error, got \(String(describing: error))")
            return
        }
    }

    func test_endpointURLs() throws {
        XCTAssertEqual(Authentication.requestToken.url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/token/new")

        XCTAssertEqual(Authentication.createSession(requestToken: "a-token").url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/session/new")

        XCTAssertEqual(Authentication.createQuestSession.url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/guest_session/new")

        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/session")
    }

    func test_createSession_HTTPBody() throws {
        let body = try XCTUnwrap(Authentication.createSession(requestToken: "a-token").httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["request_token"]))
        XCTAssertEqual(object["request_token"] as? String, "a-token")
    }

    func test_deleteSession_HTTPBody() throws {
        let body = try XCTUnwrap(Authentication.deleteSession(sessionId: "an-id").httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["session_id"]))
        XCTAssertEqual(object["session_id"] as? String, "an-id")
    }

    func test_endpointHeaders() {
        XCTAssertEqual(Authentication.requestToken.requestHeaders, [:])
        XCTAssertEqual(Authentication.createQuestSession.requestHeaders, [:])
        XCTAssertEqual(Authentication.createSession(requestToken: "a-token").requestHeaders,
                       ["Content-Type": "application/json;charset=utf-8"])
        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").requestHeaders,
                       ["Content-Type": "application/json;charset=utf-8"])
    }

    func test_httpMethod() {
        XCTAssertEqual(Authentication.requestToken.httpMethod, .GET)
        XCTAssertEqual(Authentication.createQuestSession.httpMethod, .GET)
        XCTAssertEqual(Authentication.createSession(requestToken: "a-token").httpMethod, .POST)
        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").httpMethod, .DELETE)
    }
}
