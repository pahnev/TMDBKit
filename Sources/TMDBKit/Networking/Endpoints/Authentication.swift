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

    var httpMethod: HTTPMethod {
        switch self {
        case .requestToken, .createSession, .createQuestSession:
            return .GET
        }
    }

    var httpBody: Data? {
        return nil
    }

    var requestHeaders: [String : String] {
        return [:]
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
        }
    }

}
