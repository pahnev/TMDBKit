//
//  Change.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Change: CodableEquatable {
    public struct Item: CodableEquatable {
        public let id: String
        public let action: String
        public let time: String
        public let iso6391: String
        public let value: String
        public let originalValue: String
    }

    public let key: String
    public let items: [Item]
}

public struct TVChange: CodableEquatable {
    public struct Item: CodableEquatable {
        public struct Value: CodableEquatable {
            public struct Poster: CodableEquatable {
                public let filePath: String
                public let iso6391: String?
            }
            public let poster: Poster
        }
        public let id: String
        public let action: String
        public let time: String
        public let iso6391: String
        public let iso31661: String
        public let value: Value
        public let originalValuex: Value
    }
    public let key: String
    public let items: [Item]

}
