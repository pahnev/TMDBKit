//
//  StubHelper.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 03/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation
import OHHTTPStubsSwift
import OHHTTPStubsCore

@testable import TMDBKit

class StubHelper {
    func stubWithLocalFile(_ endpoint: Endpoint) {
        print(endpoint.url.path)
        var fileName = endpoint.url.path.dropFirst().replacingOccurrences(of: "/", with: "_")

        stub(condition: isPath(endpoint.url.path)) { _ in
            // Append only append query, ignore pagination and other things
            if let query = endpoint.url.query, query.contains("append_to_response") {
                fileName.append("?\(query)")
            }
            let file = self.fixtureCache["v\(fileName).json"]
            return OHHTTPStubsResponse(data: try! Data(contentsOf: file!), statusCode: 200, headers: [:])
        }
    }

    private let fixtureCache: [String: URL]

    init() {
        var cache: [String: URL] = [:] // Save all local files in this cache
        let baseURL = StubHelper.urlForRestServicesTestsDir()

        guard let enumerator = FileManager.default.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.nameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants],
            errorHandler: nil) else {
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
