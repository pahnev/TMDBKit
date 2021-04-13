//
//  Reviews.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18/09/2019.
//

import Foundation

enum Reviews: Endpoint {
    case details(reviewId: Int)

    var httpMethod: HTTPMethod { return .GET }

    var httpBody: Data? { nil }

    var requestHeaders: [String: String] { [:] }

    var url: URL {
        switch self {
        case .details(let reviewId):
            return baseURL.appendingPathComponent("review\(reviewId)")
        }
    }
}
