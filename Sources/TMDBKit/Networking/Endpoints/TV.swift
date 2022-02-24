//
//  TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 20/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum TV: Endpoint {
    case accountStates(tvId: Int, language: String?)

    case alternativeTitles(tvId: Int, language: String?)

    case details(tvId: Int, language: String?, append: [DetailsAppendable]?)

    case aggregateCredits(tvId: Int, language: String?)

    case changes(tvId: Int, pageNumber: PageNumber)

    case contentRatings(tvId: Int, language: String?)

    case credits(tvId: Int, language: String?)

    case episodeGroups(tvId: Int, language: String?)

    case externalIds(tvId: Int, language: String?)

    case images(tvId: Int, language: String?)

    case keywords(tvId: Int)

    case recommendations(tvId: Int, pageNumber: PageNumber, language: String?)

    case reviews(tvId: Int, pageNumber: PageNumber, language: String?)

    /// Get a list of seasons or episodes that have been screened in a film festival or theatre
    case screenedTheatrically(tvId: Int)

    case similarShows(tvId: Int, pageNumber: PageNumber, language: String?)

    case translations(tvId: Int)

    case videos(tvId: Int, language: String?)

    case watchProviders(tvId: Int)

    case latest(language: String?)

    case airingToday(pageNumber: PageNumber, language: String?)

    case onTheAir(pageNumber: PageNumber, language: String?)

    case popular(pageNumber: PageNumber, language: String?)

    /// Get the top rated movies on TMDb.
    case topRated(pageNumber: PageNumber, language: String?)

    // POST
    case rateShow(tvId: Int, rating: Double)

    // DELETE
    case deleteRating(tvId: Int)

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .accountStates,
             .aggregateCredits,
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
             .watchProviders:
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
             .aggregateCredits,
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
             .deleteRating,
             .watchProviders:
            return nil
        case .rateShow(let rating, _):
            return try! JSONEncoder().encode(["value": rating])
        }
    }

    var requestHeaders: [String: String] {
        switch self {
        case .details,
             .accountStates,
             .aggregateCredits,
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
             .watchProviders:
            return [:]
        case .rateShow, .deleteRating:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        let tv = baseURL.appendingPathComponent("tv")

        switch self {
        case .details(let tvId, let language, let append):
            let tvDetails = tv
                .appendingPathComponent("\(tvId)")
                .appendingLanguage(language)
            if let append = append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return tvDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return tvDetails
        case .accountStates(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/account_states")
                .appendingLanguage(language)
        case .aggregateCredits(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/aggregate_credits")
                .appendingLanguage(language)
        case .alternativeTitles(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/alternative_titles")
                .appendingLanguage(language)
        case .changes(let tvId, let pageNumber):
            return tv
                .appendingPathComponent("\(tvId)/changes")
                .appendingPage(pageNumber)
        case .credits(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/credits")
                .appendingLanguage(language)
        case .episodeGroups(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/episode_groups")
                .appendingLanguage(language)
        case .externalIds(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/external_ids")
                .appendingLanguage(language)
        case .images(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/images")
                .appendingLanguage(language)
        case .keywords(let tvId):
            return tv.appendingPathComponent("\(tvId)/keywords")
        case .videos(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/videos")
                .appendingLanguage(language)
        case .translations(let tvId):
            return tv.appendingPathComponent("\(tvId)/translations")
        case .recommendations(let tvId, let page, let language):
            return tv
                .appendingPathComponent("\(tvId)/recommendations")
                .appendingPage(page)
                .appendingLanguage(language)
        case .similarShows(let tvId, let page, let language):
            return tv
                .appendingPathComponent("\(tvId)/similar")
                .appendingPage(page)
                .appendingLanguage(language)
        case .reviews(let tvId, let page, let language):
            return tv
                .appendingPathComponent("\(tvId)/reviews")
                .appendingPage(page)
                .appendingLanguage(language)
        case .popular(let page, let language):
            return tv
                .appendingPathComponent("popular")
                .appendingPage(page)
                .appendingLanguage(language)
        case .latest(let language):
            return tv
                .appendingPathComponent("latest")
                .appendingLanguage(language)
        case .topRated(let page, let language):
            return tv
                .appendingPathComponent("top_rated")
                .appendingPage(page)
                .appendingLanguage(language)
        case .airingToday(let page, let language):
            return tv
                .appendingPathComponent("airing_today")
                .appendingPage(page)
                .appendingLanguage(language)
        case .onTheAir(let page, let language):
            return tv
                .appendingPathComponent("on_the_air")
                .appendingPage(page)
                .appendingLanguage(language)
        case .contentRatings(let tvId, let language):
            return tv
                .appendingPathComponent("\(tvId)/content_ratings")
                .appendingLanguage(language)
        case .screenedTheatrically(let tvId):
            return tv
                .appendingPathComponent("\(tvId)/screened_theatrically")
        case .watchProviders(let tvId):
            return tv.appendingPathComponent("\(tvId)/watch/providers")
        case .rateShow(let tvId, _):
            return tv.appendingPathComponent("\(tvId)/rating")
        case .deleteRating(let tvId):
            return tv.appendingPathComponent("\(tvId)/rating")
        }
    }
}
