//
//  File.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import Foundation
import TMDBKit

struct MockAuth: Authenticator {
    var apiKey: String {
//        return "e8d272ad21f324980fa9c7f876b1fe1b"

        return "e8d272ad21f324980fa9c7f876b1fe1b"
    }

    var sessionId: String? {
        return "456"
    }
}
