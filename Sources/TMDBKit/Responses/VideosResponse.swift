//
//  VideosResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

// TODO: Combine

public struct VideosResponse: CodableEquatable {
    public let id: Int
    public let results: [Video]
}

public struct AppendedVideos: CodableEquatable {
    public let results: [Video]
}
