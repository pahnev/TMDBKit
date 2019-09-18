//
//  ReleaseDateResult.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct ReleaseDateResult: CodableEquatable {
    public let iso31661: String
    public let releaseDates: [ReleaseDate]
}
