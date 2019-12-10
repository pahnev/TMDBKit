//
//  CacheConfig+Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Cache
import Foundation

extension Movies: CacheConfigurable {
    static let allCases: [CacheConfigurable] = {
        var allCases: [Movies] = []
        switch Movies.accountStates(movieId: 0, sessionsId: "") {
        case .deleteRating, .rateMovie: // Not adding, these endpoints should not be cached
            fallthrough
        case .accountStates: allCases.append(.accountStates(movieId: 0, sessionsId: ""))
            fallthrough
        case .alternativeTitles: allCases.append(.alternativeTitles(movieId: 0))
            fallthrough
        case .changes: allCases.append(.changes(movieId: 0))
            fallthrough
        case .credits: allCases.append(.credits(movieId: 0))
            fallthrough
        case .details: allCases.append(.details(movieId: 0, append: nil))
            fallthrough
        case .externalIds: allCases.append(.externalIds(movieId: 0))
            fallthrough
        case .images: allCases.append(.images(movieId: 0))
            fallthrough
        case .keywords: allCases.append(.keywords(movieId: 0))
            fallthrough
        case .latest: allCases.append(.latest)
            fallthrough
        case .lists: allCases.append(.lists(movieId: 0, pageNumber: 0))
            fallthrough
        case .nowPlaying: allCases.append(.nowPlaying(pageNumber: 0))
            fallthrough
        case .popular: allCases.append(.popular(pageNumber: 0))
            fallthrough
        case .recommendations: allCases.append(.recommendations(movieId: 0, pageNumber: 0))
            fallthrough
        case .releaseDates: allCases.append(.releaseDates(movieId: 0))
            fallthrough
        case .reviews: allCases.append(.reviews(movieId: 0, pageNumber: 0))
            fallthrough
        case .similarMovies: allCases.append(.similarMovies(movieId: 0, pageNumber: 0))
            fallthrough
        case .topRated: allCases.append(.topRated(pageNumber: 0))
            fallthrough
        case .translations: allCases.append(.translations(movieId: 0))
            fallthrough
        case .upcoming: allCases.append(.upcoming(pageNumber: 0))
            fallthrough
        case .videos: allCases.append(.videos(movieId: 0))
        return allCases

        }
    }()

    var name: String {
        switch self {
        case .accountStates:
            return "movieAccountStates"
        case .alternativeTitles:
            return "alternativeMovieTitles"
        case .changes:
            return "movieChanges"
        case .credits:
            return "movieCredits"
        case .details:
            return "movieDetails"
        case .externalIds:
            return "movieExternalIds"
        case .images:
            return "movieImages"
        case .keywords:
            return "movieKeywords"
        case .latest:
            return "latestMovies"
        case .lists:
            return "movieLists"
        case .nowPlaying:
            return "nowPlayingMovies"
        case .popular:
            return "popularMovies"
        case .recommendations:
            return "movieRecommendations"
        case .releaseDates:
            return "movieReleaseDates"
        case .reviews:
            return "movieReviews"
        case .similarMovies:
            return "similarMovies"
        case .topRated:
            return "topRatedMovies"
        case .translations:
            return "movieTranslations"
        case .upcoming:
            return "upcomingMovies"
        case .videos:
            return "movieVideos"
        case .deleteRating, .rateMovie:
            preconditionFailure("This endpoint shouldn't be configured for caching")
        }
    }

    var key: String {
        switch self {
        case .accountStates(let movieId, _):
            return "accountStates_\(movieId)"
        case .alternativeTitles(let movieId):
            return "alternativeTitles_\(movieId)"
        case .changes(let movieId):
            return "changes_\(movieId)"
        case .credits(let movieId):
            return "credits_\(movieId)"
        case .details(let params):
            return "details_\(params.movieId)_\(params.append?.debugDescription ?? "")"
        case .externalIds(let movieId):
            return "externalIds_\(movieId)"
        case .images(let movieId):
            return "images_\(movieId)"
        case .keywords(let movieId):
            return "keywords_\(movieId)"
        case .latest:
            return "latestMovies"
        case .lists(let movieId, let pageNumber):
            return "lists_\(movieId)_\(pageNumber)"
        case .nowPlaying(let pageNumber):
            return "nowPlayingMovies_\(pageNumber)"
        case .popular(let pageNumber):
            return "popularMovies_\(pageNumber)"
        case .recommendations(let movieId, let pageNumber):
            return "recommendations_\(movieId)_\(pageNumber)"
        case .releaseDates(let movieId):
            return "releaseDates_\(movieId)"
        case .reviews(let movieId, let pageNumber):
            return "reviews_\(movieId)_\(pageNumber)"
        case .similarMovies(let movieId, let pageNumber):
            return "similarMovies_\(movieId)_\(pageNumber)"
        case .topRated(let pageNumber):
            return "topRatedMovies_\(pageNumber)"
        case .translations(let movieId):
            return "translations_\(movieId)"
        case .upcoming(let pageNumber):
            return "upcomingMovies_\(pageNumber)"
        case .videos(let movieId):
            return "videos_\(movieId)"
        case .deleteRating, .rateMovie:
            preconditionFailure("This endpoint shouldn't be configured for caching")
        }
    }

    var diskMaxSize: UInt {
        let MB = UInt(1024 * 1024)
        switch self {
        case .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .details,
             .externalIds,
             .images,
             .keywords,
             .recommendations,
             .releaseDates,
             .reviews,
             .similarMovies,
             .translations,
             .videos:
            return MB * 50
        case .latest:
            return MB
        case .lists, .nowPlaying, .popular, .topRated, .upcoming:
            return MB * 5
        case .deleteRating, .rateMovie:
            preconditionFailure("This endpoint shouldn't be configured for caching")
        }
    }

    var memoryMaxItemCount: UInt {
        switch self {
        case .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .details,
             .externalIds,
             .images,
             .keywords,
             .recommendations,
             .releaseDates,
             .reviews,
             .similarMovies,
             .translations,
             .videos:
            return 500
        case .latest:
            return 1
        case .lists, .nowPlaying, .popular, .topRated, .upcoming:
            return 50
        case .deleteRating, .rateMovie:
            preconditionFailure("This endpoint shouldn't be configured for caching")
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
