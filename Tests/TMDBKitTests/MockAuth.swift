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
        return "123"
    }
    var sessionId: String? {
        return nil
    }
}
