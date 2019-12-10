//
//  PersonImageResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

public struct PersonImageResponse: CodableEquatable {
    public let id: Int
    public let profiles: [Image]
}
