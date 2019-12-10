//
//  Cache.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Cache
import Foundation

final class Cache {
    // Key: CacheConfig.name, Value: Storage instance for that CacheConfig
    private let storages: [String: Storage]

    init() throws {
        // Create a Storage instance for each CacheConfig case and store it by using CacheConfig case's name as key
        self.storages = try CacheConfig.allCases.reduce([:], { current, cacheConfig in

            var dict = current
            dict[cacheConfig.name] = try cacheConfig.createCache()
            return dict
        })
    }

    func storage(for config: CacheConfigurable) -> Storage {
        guard let storage = storages[config.name] else { preconditionFailure() }
        return storage
    }

    func totalDiskStorageSize() -> Int {
        return CacheConfig.allCases.reduce(0, { previousSize, cacheConfig in
            return previousSize + cacheConfig.diskStorageSize
        })
    }

    func clearCaches() throws {

        try CacheConfig.allCases.forEach { try storage(for: $0).removeAll() }
    }
}

