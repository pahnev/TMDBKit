//
//  ProductionCompany.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 02/08/2018.
//

import Foundation

public struct ProductionCompany: CodableEquatable {
    public let id: Int
    public let name: String
    public let logoPath: String?
    public let originCountry: String
}
