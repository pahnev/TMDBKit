//
//  Caching.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Cache
import Foundation

protocol CacheConfigurable {
    var name: String { get }
    var key: String { get }
    var diskMaxSize: UInt { get }
    var memoryMaxItemCount: UInt { get }
    static var allCases: [CacheConfigurable] { get }

    func createCache() throws -> Storage
    var diskStorageSize: Int { get }
}

enum CacheConfig: CacheConfigurable {
    static var allCases: [CacheConfigurable] {
        return Movies.allCases
    }

    case movies(Movies)

    var name: String {
        switch self {
        case .movies(let config): return config.name
        }
    }

    var key: String {
        switch self {
        case .movies(let config): return config.key
        }
    }

    var diskMaxSize: UInt {
        switch self {
        case .movies(let config): return config.diskMaxSize
        }
    }

    var memoryMaxItemCount: UInt {
        switch self {
        case .movies(let config): return config.memoryMaxItemCount
        }
    }

    var diskStorageSize: Int {
        let url = cacheDirectoryURL().appendingPathComponent(name)
        guard let files = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            print("Couldn't list files in \(url)")
            return 0
        }

        let totalSize = files.reduce(0) { previousSize, fileURL -> Int in
            let resourceValues: URLResourceValues? = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
            let size = resourceValues?.fileSize ?? 0
            return previousSize + size
        }
        return totalSize
    }

    func storage(with cache: Cache) -> Storage {
        return cache.storage(for: self)
    }

    func createCache() throws -> Storage {
        let diskConfig = DiskConfig(name: name,
                                    expiry: .never,
                                    maxSize: diskMaxSize,
                                    directory: cacheDirectoryURL(),
                                    protectionType: nil)

        let memoryConfig = MemoryConfig(expiry: .never,
                                        countLimit: memoryMaxItemCount,
                                        totalCostLimit: memoryMaxItemCount)

        return try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)

    }

    private func cacheDirectoryURL() -> URL {
        final class InternalClassForBundleLoader {}
        guard let bundleIdentifier = Bundle(for: InternalClassForBundleLoader.self).bundleIdentifier else { preconditionFailure("Missing bundleIdentifier") }
        let storeDirectoryName = "recipekit-store"
        let dirSubPath = "/" + bundleIdentifier + "/" + storeDirectoryName

        guard let cacheBaseDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            preconditionFailure("No caches directory path in system")
        }

        return URL(fileURLWithPath: cacheBaseDirPath + dirSubPath)
    }
}
