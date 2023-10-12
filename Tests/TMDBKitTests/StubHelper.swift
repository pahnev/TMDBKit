//
//  StubHelper.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 03/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation
import XCTest
@testable import TMDBKit

class StubHelper {
    func stubEndpoint(_ endpoint: Endpoint, with response: [String: Any]) throws {
        MockURLProtocol.requestHandler = { _ in
            let data = try JSONSerialization.data(withJSONObject: response, options: [])
            return (HTTPURLResponse(url: endpoint.url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    func stubWithLocalFile(_ endpoint: Endpoint) throws {
        print("🗣 STUBBING: \(endpoint.url.path) ")

        MockURLProtocol.requestHandler = { _ in
            var fileName = endpoint.url.path.dropFirst().replacingOccurrences(of: "/", with: "_")
            if let query = endpoint.url.query {
                if query.contains("append_to_response") {
                    fileName.append("?\(query)")
                } else if query.contains("request_token") {
                    fileName.append("?\(query)")
                }
            }
            let file = try XCTUnwrap(self.fixtureCache["v\(fileName).json"])
            let data = try Data(contentsOf: file)

            return (HTTPURLResponse(url: endpoint.url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    private let fixtureCache: [String: URL]

    init() {
        var cache: [String: URL] = [:] // Save all local files in this cache
        let baseURL = StubHelper.urlForRestServicesTestsDir()

        guard let enumerator = FileManager.default.enumerator(at: baseURL,
                                                              includingPropertiesForKeys: [.nameKey],
                                                              options: [.skipsHiddenFiles, .skipsPackageDescendants],
                                                              errorHandler: nil)
        else {
            fatalError("Could not enumerate \(baseURL)")
        }

        for case let url as URL in enumerator where url.isFileURL {
            cache[url.lastPathComponent] = url
        }
        fixtureCache = cache
    }

    private static func urlForRestServicesTestsDir() -> URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
