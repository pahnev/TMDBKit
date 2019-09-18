//
//  ReleaseDate.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct ReleaseDate: CodableEquatable {
    public let certification: String
    public let iso6391: String
    public let releaseDate: String
    public let type: Int
    public let note: String?
}
