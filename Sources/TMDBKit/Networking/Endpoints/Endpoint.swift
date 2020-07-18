//
//  Endpoint.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public typealias PageNumber = Int

public enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

public enum CachePolicy {
    case allowed
    case never
}

protocol Endpoint {
    var httpMethod: HTTPMethod { get }
    var httpBody: Data? { get }
    var requestHeaders: [String: String] { get }
    var url: URL { get }
    var cachePolicy: CachePolicy { get }
}

extension Endpoint {
    var httpMethod: HTTPMethod { return .GET }
    var httpBody: Data? { return nil }
    var requestHeaders: [String : String] { return [:] }
    var cachePolicy: CachePolicy { .allowed }
}

let baseURL = URL(string: "https://api.themoviedb.org/3/")!
