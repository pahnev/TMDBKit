//
//  AccountDetails.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18.7.2020.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct AccountDetails: CodableEquatable {
    public struct Avatar: CodableEquatable {
        public struct Gravatar: CodableEquatable {
            public let hash: String
        }
        public let gravatar: Gravatar
    }

    public let avatar: Avatar
    public let id: Int
    public let iso6391: String
    public let iso31661: String
    public let name: String
    public let includeAdult: Bool
    public let username: String
}
