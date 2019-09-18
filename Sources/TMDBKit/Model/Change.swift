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
