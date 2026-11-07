//
//  ExternalIds.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct ExternalIds: CodableEquatable {
    public let wikidataId: String?
    public let freebaseMid: String?
    public let freebaseId: String?
    public let tiktokId: String?
    public let tvdbId: Int?
    public let tvrageId: Int?
    public let imdbId: String?
    public let facebookId: String?
    public let instagramId: String?
    public let twitterId: String?
    public let id: Int
}
