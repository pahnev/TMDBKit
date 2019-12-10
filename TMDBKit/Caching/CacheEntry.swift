//
//  CacheEntry.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

/** Generic struct which represents a cache entry.
 Cache entry consists of:
 - Value
 - Optional metadata
 */
struct CacheEntry<ValueType: CodableEquatable>: CodableEquatable {
    var value: ValueType
    let etag: String?
    let expirationDate: Date?

    init(value: ValueType, maxAge: TimeInterval?, etag: String?) {
        self.value = value
        self.etag = etag
        self.expirationDate = Date.withTimeIntervalSinceNow(maxAge)
    }

    mutating func setValue(_ value: ValueType) {
        self.value = value
    }
}

private extension Date {
    static func withTimeIntervalSinceNow(_ timeInterval: TimeInterval?) -> Date? {
        guard let timeInterval = timeInterval else { return nil }
        return Date().addingTimeInterval(timeInterval)
    }
}
