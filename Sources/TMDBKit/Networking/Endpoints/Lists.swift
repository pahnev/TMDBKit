//
//  Lists.swift
//
//
//  Created by Pahnev, Kirill on 13.4.2021.
//

import Foundation

enum Lists: Endpoint {
    struct List: Encodable {
        let name: String
        let description: String
        let language: String
    }

    case createList(list: List)
    case details(listId: String, language: String?)
    case itemStatus(listId: String, movieId: Int)
    case addMovie(listId: String, mediaId: Int)
    case removeMovie(listId: String, mediaId: Int)
    case clearList(listId: String)
    case deleteList(listId: String)

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .itemStatus:
            return .GET
        case .createList,
             .addMovie,
             .removeMovie,
             .clearList:
            return .POST
        case .deleteList:
            return .DELETE
        }
    }

    var httpBody: Data? {
        switch self {
        case .details,
             .itemStatus,
             .clearList,
             .deleteList:
            return nil
        case .createList(let list):
            return try! JSONEncoder().encode(list)
        case .addMovie(_, let mediaId),
             .removeMovie(_, let mediaId):
            return try! JSONEncoder().encode(["media_id": mediaId])
        }
    }

    var requestHeaders: [String: String] {
        switch self {
        case .details,
             .itemStatus,
             .deleteList:
            return [:]
        case .createList,
             .addMovie,
             .removeMovie,
             .clearList:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        let lists = baseURL.appendingPathComponent("list")
        switch self {
        case .details(let listId, let language):
            return lists
                .appendingPathComponent("\(listId)")
                .appendingLanguage(language)
        case .itemStatus(let listId, let movieId):
            return lists
                .appendingPathComponent("\(listId)/item_status")
                .appendingQueryItem(URLQueryItem(name: "movie_id", value: "\(movieId)"))
        case .createList:
            return lists
        case .addMovie(let listId, _):
            return lists.appendingPathComponent("\(listId)/add_item")
        case .removeMovie(let listId, _):
            return lists.appendingPathComponent("\(listId)/remove_item")
        case .clearList(let listId):
            return lists.appendingPathComponent("\(listId)/clear")
        case .deleteList(let listId):
            return lists.appendingPathComponent("\(listId)")
        }
    }
}
