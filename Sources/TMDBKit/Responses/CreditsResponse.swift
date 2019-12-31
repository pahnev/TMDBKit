//
//  CreditsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct CreditsResponse: CodableEquatable {
    public let id: Int
    public let cast: [Cast]
    public let crew: [Crew]
}

public struct TVCreditsResponse: CodableEquatable {
    public let id: Int
    public let cast: [TVCast]
    public let crew: [Crew]
}

public struct AppendedCredits: CodableEquatable {
    public let cast: [Cast]
    public let crew: [Crew]
}
