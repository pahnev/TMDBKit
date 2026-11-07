//
//  ReleaseDate.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct ReleaseDate: CodableEquatable {
    /// Element schema is unspecified; preserve arbitrary JSON descriptor values.
    public let descriptors: [ChangeValue]?
    public let certification: String
    public let iso6391: String
    public let releaseDate: String
    public let type: Int
    public let note: String?
}
