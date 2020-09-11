//
//  Authenticator.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 30/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public protocol Authenticator {

    /// The API key for the TMDB. Required for all requests.
    var apiKey: String { get }

    /// The session id required to get and set user data.
    /// You should treat this like a password and keep it secret.
    /// See `createRequestToken:completion:` and `createSession:requestToken:` for details how to generate a `sessionId`.
    var sessionId: String? { get }
}
