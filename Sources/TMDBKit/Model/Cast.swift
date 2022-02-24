//
//  Cast.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Cast: CodableEquatable {
    public let adult: Bool
    public let character: String
    public let creditId: String
    public let gender: Int
    public let id: Int
    public let knownForDepartment: String
    public let name: String
    public let originalName: String
    public let order: Int
    public let popularity: Double
    public let profilePath: String?
}

public struct TVCast: CodableEquatable {
    public let adult: Bool
    public let character: String
    public let creditId: String
    public let gender: Int
    public let id: Int
    public let knownForDepartment: String
    public let name: String
    public let originalName: String
    public let order: Int
    public let popularity: Double
    public let profilePath: String?
}
