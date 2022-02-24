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

public struct AggregateCredits: CodableEquatable {
    public let id: Int
    public let cast: [AggregateCast]
    public let crew: [AggregateCrew]
}

public struct AggregateCast: CodableEquatable {
    public struct Role: CodableEquatable {
        public let creditId: String
        public let character: String
        public let episodeCount: Int
    }

    public let adult: Bool
    public let gender: Int
    public let id: Int
    public let knownForDepartment: String
    public let name: String
    public let originalName: String
    public let order: Int
    public let popularity: Double
    public let profilePath: String?
    public let totalEpisodeCount: Int

}

public struct AggregateCrew: CodableEquatable {
    public struct Job: CodableEquatable {
        public let creditId: String
        public let job: String
        public let episodeCount: Int
    }

    public let department: String
    public let gender: Int?
    public let id: Int
    public let name: String
    public let profilePath: String?
    public let totalEpisodeCount: Int
}
