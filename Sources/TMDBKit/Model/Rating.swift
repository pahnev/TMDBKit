//
//  Rating.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct Rating: CodableEquatable {
    public let rating: String
    public let iso31661: String
}
