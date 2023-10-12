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
            assertionFailure("Invalid url \(self)")
            return self
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

    func appendingSort(_ sort: Sort) -> URL {
        switch sort {
            case .createdAt(let direction):
                return appendingQueryItem(URLQueryItem(name: "sort_by", value: "created_at.\(direction.urlQuery)"))
        }
    }

    func appendingAccountId(_ accountId: Int?) -> URL {
        appendingPathComponent(String(accountId ?? 0))
    }

    func appendingLanguage(_ language: String?) -> URL {
        guard let language = language else {
            return self
        }
        return appendingQueryItem(URLQueryItem(name: "language", value: language))
    }

    func appendingCountry(_ country: String?) -> URL {
        guard let country = country else {
            return self
        }
        return appendingQueryItem(URLQueryItem(name: "country", value: country))
    }

    func appendingRegion(_ region: String?) -> URL {
        guard let region = region else {
            return self
        }
        return appendingQueryItem(URLQueryItem(name: "region", value: region))
    }

    func appendingSortedPagination(_ pagination: SortedPagination) -> URL {
        var url = self
        if let sort = pagination.sortBy {
            url = url.appendingSort(sort)
        }
        if let page = pagination.page {
            url = url.appendingPage(page)
        }
        return url
    }
}
