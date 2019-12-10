//
//  CacheConfig+People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Cache
import Foundation

extension People: CacheConfigurable {
    static var allCases: [CacheConfigurable] {
        var allCases: [People] = []
        switch People.images(personId: 0) {
        case .images: allCases.append(.images(personId: 0))
        }
        return allCases
    }

    var name: String {
        switch self {
        case .images:
            return "peopleImages"
        }
    }

    var key: String {
        switch self {
        case .images(let personId):
            return "peopleImages_\(personId)"
        }
    }

    var diskMaxSize: UInt {
        let MB = UInt(1024 * 1024)
        switch self {
        case .images:
            return MB * 50
        }
    }

    var memoryMaxItemCount: UInt {
        switch self {
        case .images:
            return 500
        }
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

    private func cacheDirectoryURL() -> URL {
        final class InternalClassForBundleLoader {}
        guard let bundleIdentifier = Bundle(for: InternalClassForBundleLoader.self).bundleIdentifier else { preconditionFailure("Missing bundleIdentifier") }
        let storeDirectoryName = "tmdbkit-store"
        let dirSubPath = "/" + bundleIdentifier + "/" + storeDirectoryName

        guard let cacheBaseDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            preconditionFailure("No caches directory path in system")
        }

        return URL(fileURLWithPath: cacheBaseDirPath + dirSubPath)
    }

}
