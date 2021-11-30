//
//  URL+QueryItem.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

extension URL {
    func appendingQueryItem(_ queryItem: URLQueryItem) -> URL {
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid url \(self)")
        }

        let currentQueryItems = urlComps.queryItems ?? []
        urlComps.queryItems = currentQueryItems + [queryItem]

        return urlComps.url!
    }

    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        var url = self
        queryItems.forEach { url = url.appendingQueryItem($0) }
        return url
    }

    func appendingPage(_ pageNumber: Int) -> URL {
        appendingQueryItem(URLQueryItem(name: "page", value: "\(pageNumber)"))
    }

    func appendingSearchQuery(_ query: String) -> URL {
        appendingQueryItem(URLQueryItem(name: "query", value: query))
    }

    func appendingAccountId(_ accountId: Int?) -> URL {
        appendingPathComponent(String(accountId ?? 0))
    }

    func appendingSortedPagination(_ pagination: SortedPagination) -> URL {
        // TODO: Append sorting info
        if let page = pagination.page {
            return appendingPage(page)
        }
        return self
    }
}
