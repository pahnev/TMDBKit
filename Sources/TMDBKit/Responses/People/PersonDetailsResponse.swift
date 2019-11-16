//
//  File.swift
//  
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import Foundation

public struct PersonDetailsResponse: CodableEquatable {
    public let birthday: String?
    public let knownForDepartment: String?
    public let deathDay: String?
    public let id: Int
    public let name: String
    public let alsoKnownAs: [String]
    public let gender: Int
    public let biography: String
    public let popularity: Double
    public let placeOfBirth: String?
    public let profilePath: String?
    public let adult: Bool
    public let imdbId: String?
    public let homepage: String?
}

public struct PopularPersonResponse: CodableEquatable {
    public let page: Int
    public let totalResults: Int
    public let totalPages: Int
    public let results: [PopularPerson]

}
public struct PopularPerson: CodableEquatable {
    public let popularity: Double
    public let knownForDepartment: String?
    public let gender: Int
    public let id: Int
    public let profilePath: String?
    public let adult: Bool
    public let knownFor: [Media]
    public let name: String
}
