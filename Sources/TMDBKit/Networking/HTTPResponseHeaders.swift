//
//  HTTPResponseHeaders.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

struct HTTPResponseHeaders {
    let etag: String?
    let maxAge: TimeInterval?

    let date: Date?
    let age: TimeInterval
    let requiresRevalidation: Bool
    let allowsStorage: Bool

    private static func directives(from value: String?) -> [String] {
        return value?.lowercased().split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        } ?? []
    }

    private static func parseMaxAge(from cacheControlHeader: String?) -> TimeInterval? {
        let directive = directives(from: cacheControlHeader).first {
            $0.split(separator: "=").first?.trimmingCharacters(in: .whitespaces) == "max-age"
        }
        let pair = directive?.split(separator: "=", maxSplits: 1)
        guard let parts = pair, parts.count == 2 else { return nil }
        return TimeInterval(parts[1].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    init(_ headers: [AnyHashable: Any]) {
        var fields: [String: String] = [:]
        for (key, value) in headers {
            guard let name = key as? String, let value = value as? String else { continue }
            fields[name.lowercased()] = value
        }
        etag = fields["etag"]
        maxAge = HTTPResponseHeaders.parseMaxAge(from: fields["cache-control"])
        age = max(0, fields["age"].flatMap(TimeInterval.init) ?? 0)
        let directives = HTTPResponseHeaders.directives(from: fields["cache-control"]).map {
            $0.split(separator: "=").first?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        requiresRevalidation = directives.contains("no-cache")
        allowsStorage = !directives.contains("no-store")

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        date = fields["date"].flatMap { formatter.date(from: $0) }
    }

    func isFresh(at now: Date, storedAt: Date?) -> Bool {
        guard allowsStorage, !requiresRevalidation, let maxAge = maxAge, maxAge > 0,
              let responseDate = date ?? storedAt else { return false }
        // Imported entries lack our receipt metadata; Date still supplies their apparent age.
        let receivedAt = storedAt ?? now
        let initialAge = max(age, max(0, receivedAt.timeIntervalSince(responseDate)))
        let currentAge = initialAge + max(0, now.timeIntervalSince(receivedAt))
        return currentAge < maxAge
    }
}
