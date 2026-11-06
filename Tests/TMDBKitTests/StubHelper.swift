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
    private var expectedRequests = 0
    private var receivedRequests = 0

    func verifyRequests(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(receivedRequests, expectedRequests, file: file, line: line)
    }

    func stubEndpoint(_ endpoint: Endpoint, expecting expected: RequestExpectation, with response: [String: Any], file: StaticString = #file, line: UInt = #line) throws {
        expectedRequests += 1
        MockURLProtocol.requestHandler = { request in
            self.receivedRequests += 1
            try expected.assertRequest(request, file: file, line: line)
            let data = try JSONSerialization.data(withJSONObject: response, options: [])
            return (HTTPURLResponse(url: endpoint.url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    func stubWithLocalFile(_ endpoint: Endpoint, expecting expected: RequestExpectation, file: StaticString = #file, line: UInt = #line) throws {
        expectedRequests += 1

        MockURLProtocol.requestHandler = { request in
            self.receivedRequests += 1
            try expected.assertRequest(request, file: file, line: line)
            var fileName = endpoint.url.path.dropFirst().replacingOccurrences(of: "/", with: "_")
            if let query = endpoint.url.query {
                if query.contains("append_to_response") {
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
