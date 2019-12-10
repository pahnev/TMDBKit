//
//  Translation.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct Translation: CodableEquatable {
    public struct TranslationData: CodableEquatable {
        public let title: String
        public let overview: String
        public let homepage: String
    }

    public let data: TranslationData
    public let englishName: String
    public let iso31661: String
    public let iso6391: String
    public let name: String
}

public struct PersonTranslation: CodableEquatable {
    public struct TranslationData: CodableEquatable {
        public let biography: String
    }

    public let data: TranslationData
    public let englishName: String
    public let iso31661: String
    public let iso6391: String
    public let name: String
}
