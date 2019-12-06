//
//  TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 20/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum TV: Endpoint {
    case accountStates(tvId: Int, sessionsId: String)

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

    case rateShow(tvId: Int, rating: Double, sessionId: String)

    case deleteRating(tvId: Int, sessionId: String)

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
        case .rateShow(let params):
            return try! JSONEncoder().encode(["value": params.rating])
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
        case .details(let params):
            let tvDetails = tv.appendingPathComponent("\(params.tvId)")
            if let append = params.append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return tvDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return tvDetails
        case .accountStates(let params):
            return tv.appendingPathComponent("\(params.tvId)/account_states")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionsId))
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
        case .recommendations(let params):
            return tv.appendingPathComponent("\(params.tvId)/recommendations")
        case .similarShows(let params):
            return tv.appendingPathComponent("\(params.tvId)/similar")
        case .reviews(let params):
            return tv.appendingPathComponent("\(params.tvId)/reviews")
        case .rateShow(let params):
            return tv.appendingPathComponent("\(params.tvId)/rating")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionId))
        case .deleteRating(let params):
            return tv.appendingPathComponent("\(params.tvId)/rating")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionId))
        case .popular:
            return tv.appendingPathComponent("popular")
        case .latest:
            return tv.appendingPathComponent("latest")
        case .topRated:
            return tv.appendingPathComponent("top_rated")
        case .airingToday:
            return tv.appendingPathComponent("airing_today")
        case .onTheAir:
            return tv.appendingPathComponent("on_the_air")
        case .contentRatings(let tvId):
            return tv.appendingPathComponent("\(tvId)/content_ratings")
        case .screenedTheatrically(let tvId):
            return tv.appendingPathComponent("\(tvId)/screened_theatrically")
        }
    }
}
