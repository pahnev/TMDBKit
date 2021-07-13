//
//  Review.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Review: CodableEquatable {
    public struct AuthorDetails: CodableEquatable {
        public let avatarPath: String?
        public let name: String
        public let rating: Int?
    }

    public let id: String
    public let author: String
    public let authorDetails: AuthorDetails
    public let content: String
    public let createdAt: String
    public let updatedAt: String
    public let url: String
}
