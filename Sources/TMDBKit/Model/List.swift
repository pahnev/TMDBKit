//
//  List.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct List: CodableEquatable {
    public let description: String
    public let favoriteCount: Int
    public let id: Int
    public let iso6391: String
    public let itemCount: Int
    public let listType: String
    public let name: String
    public let posterPath: String?
}

public struct ListDetails: CodableEquatable {
    public let createdBy: String
    public let description: String
    public let favoriteCount: Int
    public let id: Int
    public let items: [MovieFragment]
    public let iso6391: String
    public let itemCount: Int
    public let listType: String
    public let name: String
    public let posterPath: String?
}

public struct ListItemStatus: CodableEquatable {
    public let id: String
    public let itemPresent: Bool
}

public struct ListCreateResponse: CodableEquatable {
    public let statusMessage: String
    public let success: Bool
    public let statusCode: Int
    public let listId: Int
}

public struct ListModificationResponse: CodableEquatable {
    public let statusMessage: String
    public let statusCode: Int
}
