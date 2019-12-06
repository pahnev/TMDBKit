//
//  KeywordsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct KeywordsResponse: CodableEquatable {
    public let id: Int
    public let keywords: [Keyword]
}

public struct TVKeywordsResponse: CodableEquatable {
    public let id: Int
    public let results: [Keyword]
}
