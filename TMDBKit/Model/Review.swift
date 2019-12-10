//
//  Review.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Review: CodableEquatable {
    public let id: String
    public let author: String
    public let content: String
    public let url: String
}
