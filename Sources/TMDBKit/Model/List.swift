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
    public let id: String
    public let items: [MovieFragment]
    public let iso6391: String
    public let itemCount: Int
    public let listType: String?
    public let name: String
    public let posterPath: String?
}

public struct ListItemStatus: CodableEquatable {
    public let id: String
    public let itemPresent: Bool
    public var numericId: Int? { Int(id) }
    // Preserve the accepted wire kind for legacy string IDs, including "001".
    private let integerWireId: Int?

    private enum CodingKeys: String, CodingKey { case id, itemPresent }
    private enum WireKeys: String, CodingKey { case id, itemPresent = "item_present" }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let integer = try container.decode(Int.self, forKey: .id)
            integerWireId = integer
            id = String(integer)
        } catch DecodingError.typeMismatch {
            integerWireId = nil
            id = try container.decode(String.self, forKey: .id)
        }
        itemPresent = try container.decode(Bool.self, forKey: .itemPresent)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WireKeys.self)
        if let integer = integerWireId {
            try container.encode(integer, forKey: .id)
        } else {
            try container.encode(id, forKey: .id)
        }
        try container.encode(itemPresent, forKey: .itemPresent)
    }
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
