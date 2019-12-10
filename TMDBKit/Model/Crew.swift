//
//  Crew.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Crew: CodableEquatable {
    public let creditId: String
    public let department: String
    public let gender: Int?
    public let id: Int
    public let job: String
    public let name: String
    public let profilePath: String?
}
