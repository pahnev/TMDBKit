//
//  AuthenticationEndpointTests.swift
//  
//
//  Created by Kirill Pahnev on 11.10.2023.
//

import XCTest
@testable import TMDBKit

final class AuthenticationEndpointTests: TMDBTestCase {

    func test_createRequestToken_returnsToken() throws {
        try stubHelper.stubWithLocalFile(Authentication.requestToken)

        let token = try awaitFor { tmdb.createRequestToken(completion: $0) }.value

        XCTAssertNotNil(token)
    }

    func test_createSession_returnsSession() throws {
        try stubHelper.stubWithLocalFile(Authentication.createSession(requestToken: "123"))
        let requestToken = RequestToken(success: true, expiresAt: "now", requestToken: "123")
        let token = try awaitFor { tmdb.createSession(requestToken: requestToken, completion: $0) }.value

        XCTAssertNotNil(token)
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
                       "https://api.themoviedb.org/3/authentication/session/new?request_token=a-token")

        XCTAssertEqual(Authentication.createQuestSession.url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/guest_session/new")

        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").url.absoluteString,
                       "https://api.themoviedb.org/3/authentication/session")
    }

    func test_createSession_HTTPBody() throws {
        let expectedData = try JSONEncoder().encode(["request_token": "a-token"])
        XCTAssertEqual(Authentication.createSession(requestToken: "a-token").httpBody, expectedData)
    }

    func test_deleteSession_HTTPBody() throws {
        let expectedData = try JSONEncoder().encode(["session_id": "an-id"])
        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").httpBody, expectedData)
    }

    func test_endpointHeaders() {
        XCTAssertEqual(Authentication.requestToken.requestHeaders, [:])
        XCTAssertEqual(Authentication.createQuestSession.requestHeaders, [:])
        XCTAssertEqual(Authentication.createSession(requestToken: "a-token").requestHeaders, 
                       ["Content-Type": "application/json;charset=utf-8"])
        XCTAssertEqual(Authentication.deleteSession(sessionId: "an-id").requestHeaders,
                       ["Content-Type": "application/json;charset=utf-8"])
    }

}
