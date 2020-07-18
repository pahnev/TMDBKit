//
//  TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 20/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum TV: Endpoint {
    case accountStates(tvId: Int)

    case alternativeTitles(tvId: Int)

    case details(tvId: Int, append: [DetailsAppendable]?)

    case changes(tvId: Int)

    case contentRatings(tvId: Int)

    case credits(tvId: Int)

    case episodeGroups(tvId: Int)

    case externalIds(tvId: Int)

    case images(tvId: Int)

    case keywords(tvId: Int)

    case recommendations(tvId: Int, pageNumber: PageNumber)

    case reviews(tvId: Int, pageNumber: PageNumber)

    /// Get a list of seasons or episodes that have been screened in a film festival or theatre
    case screenedTheatrically(tvId: Int)

    case similarShows(tvId: Int, pageNumber: PageNumber)

    case translations(tvId: Int)

    case videos(tvId: Int)

    case latest

    case rateShow(tvId: Int, rating: Double)

    case deleteRating(tvId: Int)

    case popular(pageNumber: PageNumber)

    /// Get the top rated movies on TMDb.
    case topRated(pageNumber: PageNumber)

    case airingToday(pageNumber: PageNumber)

    case onTheAir(pageNumber: PageNumber)

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .episodeGroups,
             .onTheAir,
             .contentRatings,
             .screenedTheatrically,
             .similarShows,
             .videos,
             .airingToday,
             .externalIds,
             .images,
             .keywords,
             .translations,
             .recommendations,
             .reviews,
             .popular,
             .latest,
             .topRated:
            return .GET
        case .rateShow:
            return .POST
        case .deleteRating:
            return .DELETE
        }
    }

    var httpBody: Data? {
        switch self {
        case .details,
             .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .episodeGroups,
             .onTheAir,
             .contentRatings,
             .screenedTheatrically,
             .similarShows,
             .videos,
             .airingToday,
             .externalIds,
             .images,
             .keywords,
             .translations,
             .recommendations,
             .reviews,
             .popular,
             .latest,
             .topRated,
             .deleteRating:
            return nil
        case .rateShow(let rating, _):
            return try! JSONEncoder().encode(["value": rating])
        }
    }

    var requestHeaders: [String: String] {
        switch self {
        case .details,
             .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .episodeGroups,
             .onTheAir,
             .contentRatings,
             .screenedTheatrically,
             .similarShows,
             .videos,
             .airingToday,
             .externalIds,
             .images,
             .keywords,
             .translations,
             .recommendations,
             .reviews,
             .popular,
             .latest,
             .topRated:
            return [:]
        case .rateShow, .deleteRating:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        let tv = baseURL.appendingPathComponent("tv")

        switch self {
        case .details(let tvId, let append):
            let tvDetails = tv.appendingPathComponent("\(tvId)")
            if let append = append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return tvDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return tvDetails
        case .accountStates(let tvId):
            return tv.appendingPathComponent("\(tvId)/account_states")
        case .alternativeTitles(let tvId):
            return tv.appendingPathComponent("\(tvId)/alternative_titles")
        case .changes(let tvId):
            return tv.appendingPathComponent("\(tvId)/changes")
        case .credits(let tvId):
            return tv.appendingPathComponent("\(tvId)/credits")
        case .episodeGroups(let tvId):
            return tv.appendingPathComponent("\(tvId)/episode_groups")
        case .externalIds(let tvId):
            return tv.appendingPathComponent("\(tvId)/external_ids")
        case .images(let tvId):
            return tv.appendingPathComponent("\(tvId)/images")
        case .keywords(let tvId):
            return tv.appendingPathComponent("\(tvId)/keywords")
        case .videos(let tvId):
            return tv.appendingPathComponent("\(tvId)/videos")
        case .translations(let tvId):
            return tv.appendingPathComponent("\(tvId)/translations")
        case .recommendations(let tvId, let page):
            return tv
                .appendingPathComponent("\(tvId)/recommendations")
                .appendingPage(page)
        case .similarShows(let tvId, let page):
            return tv
                .appendingPathComponent("\(tvId)/similar")
                .appendingPage(page)
        case .reviews(let tvId, let page):
            return tv
                .appendingPathComponent("\(tvId)/reviews")
                .appendingPage(page)
        case .rateShow(let tvId, _):
            return tv.appendingPathComponent("\(tvId)/rating")
        case .deleteRating(let tvId):
            return tv.appendingPathComponent("\(tvId)/rating")
        case .popular(let page):
            return tv.appendingPathComponent("popular").appendingPage(page)
        case .latest:
            return tv.appendingPathComponent("latest")
        case .topRated(let page):
            return tv.appendingPathComponent("top_rated").appendingPage(page)
        case .airingToday(let page):
            return tv.appendingPathComponent("airing_today").appendingPage(page)
        case .onTheAir(let page):
            return tv.appendingPathComponent("on_the_air").appendingPage(page)
        case .contentRatings(let tvId):
            return tv.appendingPathComponent("\(tvId)/content_ratings")
        case .screenedTheatrically(let tvId):
            return tv.appendingPathComponent("\(tvId)/screened_theatrically")
        }
    }
}
