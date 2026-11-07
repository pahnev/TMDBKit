//
//  ImagesResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct ImagesResponse: CodableEquatable {
    public let id: Int
    public let logos: [Image]?
    public let backdrops: [Image]
    public let posters: [Image]
}

public struct AppendedImages: CodableEquatable {
    public let logos: [Image]?
    public let backdrops: [Image]
    public let posters: [Image]
}

/// Profile images appended to person details; no standalone response ID is required.
public struct AppendedPersonImages: CodableEquatable {
    public let profiles: [Image]
}
