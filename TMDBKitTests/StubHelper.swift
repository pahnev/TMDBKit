//
//  StubHelper.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 03/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation
import OHHTTPStubs
@testable import TMDBKit

class StubHelper {
    func stubWithLocalFile(_ endpoint: Endpoint) {
        print(endpoint.url.path)
        let fileName = endpoint.url.path.dropFirst().replacingOccurrences(of: "/", with: "_")

        stub(condition: isPath(endpoint.url.path)) { _ in
            let stubPath = OHPathForFile("v\(fileName).json", type(of: self))!
            return fixture(filePath: stubPath, status: 200, headers: nil)
        }

    }
}
