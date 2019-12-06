//
//  ContentRatingsResponse.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct ContentRatingsResponse: CodableEquatable {
    public let id: Int
    public let results: [Rating]
}
