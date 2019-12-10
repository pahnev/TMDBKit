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
