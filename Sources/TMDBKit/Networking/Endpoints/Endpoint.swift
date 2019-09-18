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

protocol Endpoint {
    var httpMethod: HTTPMethod { get }
    var httpBody: Data? { get }
    var requestHeaders: [String: String] { get }
    var url: URL { get }
}

let baseURL = URL(string: "https://api.themoviedb.org/3/")!
