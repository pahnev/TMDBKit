//
//  People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

enum People: Endpoint {
    case images(personId: Int)

    var httpMethod: HTTPMethod {
        switch self {
        case .images:
            return .GET
        }
    }

    var httpBody: Data? {
        switch self {
        case .images:
            return nil
        }
    }

    var requestHeaders: [String : String] {
        switch self {
        case .images:
            return [:]
        }
    }

    var url: URL {
        guard let baseURL = URL(string: "https://api.themoviedb.org/3/") else {
            preconditionFailure("Invalid URL string")
        }
        let people = baseURL.appendingPathComponent("person")

        switch self {
        case .images(let personId):
            return people.appendingPathComponent("\(personId)/images")
        }
    }

}
