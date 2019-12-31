//
//  TranslationsResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct TranslationsResponse: CodableEquatable {
    public let id: Int
    public let translations: [Translation]
}

public struct PersonTranslationResponse: CodableEquatable {
    public let id: Int
    public let translations: [PersonTranslation]
}

public struct AppendedTranslations: CodableEquatable {
    public let translations: [Translation]
}
