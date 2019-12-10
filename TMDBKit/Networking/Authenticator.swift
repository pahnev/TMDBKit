//
//  Authenticator.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 30/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public protocol Authenticator {
    var apiKey: String { get }
    var sessionId: String? { get }
}
