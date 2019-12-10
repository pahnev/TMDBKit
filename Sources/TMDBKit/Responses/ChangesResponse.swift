//
//  ChangesResponse.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 04/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public struct ChangesResponse: CodableEquatable {
    public let changes: [Change]?
}
