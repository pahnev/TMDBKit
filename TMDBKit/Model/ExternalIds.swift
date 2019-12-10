//
//  ExternalIds.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct ExternalIds: CodableEquatable {
    public let imdbId: String?
    public let facebookId: String?
    public let instagramId: String?
    public let twitterId: String?
    public let id: Int
}
