//
//  AlternativeTitlesResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 03/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct AlternativeTitlesResponse: CodableEquatable {
    public let id: Int
    public let titles: [AlternativeTitle]
}

public struct AlternativeTvTitlesResponse: CodableEquatable {
    public let id: Int
    public let results: [AlternativeTitle]
}
