//
//  Authentication.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 05/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum Authentication: Endpoint {
    case requestToken
    case createSession(requestToken: String)
    case createQuestSession
    case deleteSession(sessionId: String)

    var httpMethod: HTTPMethod {
        switch self {
        case .requestToken, .createQuestSession:
            return .GET
        case .createSession:
            return .POST
        case .deleteSession:
            return .DELETE
        }
    }

    var httpBody: Data? {
        switch self {
        case .requestToken, .createQuestSession:
            return nil
        case .createSession(let requestToken):
            return try! JSONEncoder().encode(["request_token": requestToken])
        case .deleteSession(let sessionId):
            return try! JSONEncoder().encode(["session_id": sessionId])
        }
    }

    var requestHeaders: [String : String] {
        switch self {
        case .requestToken, .createQuestSession:
            return [:]
        case .createSession, .deleteSession:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        guard let baseURL = URL(string: "https://api.themoviedb.org/3/") else {
            preconditionFailure("Invalid URL string")
        }
        let authentication = baseURL.appendingPathComponent("authentication")

        switch self {
        case .requestToken:
            return authentication.appendingPathComponent("token/new")
        case .createSession(let token):
            return authentication
                .appendingPathComponent("session/new")
                .appendingQueryItem(URLQueryItem(name: "request_token", value: token))
        case .createQuestSession:
            return authentication.appendingPathComponent("guest_session/new")
        case .deleteSession:
            return authentication.appendingPathComponent("session")
        }
    }

}
