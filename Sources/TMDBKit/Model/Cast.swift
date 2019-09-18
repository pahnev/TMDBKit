//
//  Cast.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Cast: CodableEquatable {
    public let castId: Int
    public let character: String
    public let creditId: String
    public let gender: Int?
    public let id: Int
    public let name: String
    public let order: Int
    public let profilePath: String?
}
