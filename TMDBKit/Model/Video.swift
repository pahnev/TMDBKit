//
//  Video.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Video: CodableEquatable {
    public let id: String
    public let iso31661: String
    public let iso6391: String
    public let key: String
    public let name: String
    public let site: String
    /// Allowed Values: 360, 480, 720, 1080
    public let size: Int
    /// Allowed Values: Trailer, Teaser, Clip, Featurette
    public let type: String
}
