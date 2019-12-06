//
//  EpisodeGroupResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 06/12/2019.
//

import Foundation

public struct EpisodeGroupsResponse: CodableEquatable {
    public let results: [GroupResult]?
    public let id: Int
}

public struct GroupResult: CodableEquatable {
    public let description: String
    public let episodeCount: Int
    public let groupCount: Int
    public let id: String
    public let name: String
    public let network: Network?
    public let type: Int
}
