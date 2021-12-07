//
//  Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 30/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum Movies: Endpoint {
    case accountStates(movieId: Int)

    case alternativeTitles(movieId: Int, country: String?)

    case changes(movieId: Int)

    case credits(movieId: Int, language: String?)

    case deleteRating(movieId: Int)

    /// Get the most newly created movie. This is a live response and will continuously change.
    /// Get the primary information about a movie
    case details(movieId: Int, append: [DetailsAppendable]?, language: String?)

    case externalIds(movieId: Int)

    case images(movieId: Int, language: String?)

    case keywords(movieId: Int)

    case latest(language: String?)

    /// Get a list of movies in theaters. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region parameter which will narrow the search to only look for theatrical release dates within the specified country.
    case lists(movieId: Int, pageNumber: PageNumber, language: String?)

    case nowPlaying(pageNumber: PageNumber, language: String?, region: String?)

    /// Get a list of the current popular movies on TMDb. This list updates daily.
    case popular(pageNumber: PageNumber, language: String?, region: String?)

    /// Get the top rated movies on TMDb.
    case rateMovie(rating: Double, movieId: Int)

    case recommendations(movieId: Int, pageNumber: PageNumber, language: String?)

    case releaseDates(movieId: Int)

    case reviews(movieId: Int, pageNumber: PageNumber, language: String?)

    case similarMovies(movieId: Int, pageNumber: PageNumber, language: String?)

    case topRated(pageNumber: PageNumber, language: String?, region: String?)

    /// Get a list of upcoming movies in theaters. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region parameter which will narrow the search to only look for theatrical release dates within the specified country.
    case translations(movieId: Int)

    case upcoming(pageNumber: PageNumber, language: String?, region: String?)
    case videos(movieId: Int, language: String?)
    case watchProviders(movieId: Int)

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .accountStates,
             .alternativeTitles,
             .changes,
             .credits,
             .externalIds,
             .images,
             .keywords,
             .releaseDates,
             .videos,
             .watchProviders,
             .translations,
             .recommendations,
             .similarMovies,
             .reviews,
             .lists,
             .popular,
             .latest,
             .topRated,
             .nowPlaying,
             .upcoming:
            return .GET
        case .rateMovie:
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
             .externalIds,
             .images,
             .keywords,
             .releaseDates,
             .videos,
             .watchProviders,
             .translations,
             .recommendations,
             .similarMovies,
             .reviews,
             .lists,
             .popular,
             .latest,
             .topRated,
             .nowPlaying,
             .upcoming,
             .deleteRating:
            return nil
        case .rateMovie(let rating, _):
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
             .externalIds,
             .images,
             .keywords,
             .releaseDates,
             .videos,
             .watchProviders,
             .translations,
             .recommendations,
             .similarMovies,
             .reviews,
             .lists,
             .popular,
             .latest,
             .topRated,
             .nowPlaying,
             .upcoming:
            return [:]
        case .rateMovie, .deleteRating:
            return ["Content-Type": "application/json;charset=utf-8"]
        }
    }

    var url: URL {
        let movies = baseURL.appendingPathComponent("movie")

        switch self {
        case .details(let movieId, let append, let lang):
            let movieDetails = movies
                .appendingPathComponent("\(movieId)")
                .appendingLanguage(lang)
            if let append = append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return movieDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return movieDetails
        case .accountStates(let movieId):
            return movies.appendingPathComponent("\(movieId)/account_states")
        case .alternativeTitles(let movieId, let country):
            return movies
                .appendingPathComponent("\(movieId)/alternative_titles")
                .appendingCountry(country)
        case .changes(let movieId):
            return movies.appendingPathComponent("\(movieId)/changes")
        case .credits(let movieId, let lang):
            return movies
                .appendingPathComponent("\(movieId)/credits")
                .appendingLanguage(lang)
        case .externalIds(let movieId):
            return movies.appendingPathComponent("\(movieId)/external_ids")
        case .images(let movieId, let lang):
            return movies
                .appendingPathComponent("\(movieId)/images")
                .appendingLanguage(lang)
        case .keywords(let movieId):
            return movies.appendingPathComponent("\(movieId)/keywords")
        case .releaseDates(let movieId):
            return movies.appendingPathComponent("\(movieId)/release_dates")
        case .videos(let movieId, let lang):
            return movies
                .appendingPathComponent("\(movieId)/videos")
                .appendingLanguage(lang)
        case .watchProviders(let movieId):
            return movies.appendingPathComponent("\(movieId)/watch/providers")
        case .translations(let movieId):
            return movies.appendingPathComponent("\(movieId)/translations")
        case .recommendations(let movieId, let page, let lang):
            return movies
                .appendingPathComponent("\(movieId)/recommendations")
                .appendingPage(page)
                .appendingLanguage(lang)
        case .similarMovies(let movieId, let page, let lang):
            return movies
                .appendingPathComponent("\(movieId)/similar_movies")
                .appendingPage(page)
                .appendingLanguage(lang)
        case .reviews(let movieId, let page, let lang):
            return movies
                .appendingPathComponent("\(movieId)/reviews")
                .appendingPage(page)
                .appendingLanguage(lang)
        case .lists(let movieId, let page, let lang):
            return movies
                .appendingPathComponent("\(movieId)/lists")
                .appendingPage(page)
                .appendingLanguage(lang)
        case .rateMovie(_, let movieId):
            return movies.appendingPathComponent("\(movieId)/rating")
        case .deleteRating(let movieId):
            return movies.appendingPathComponent("\(movieId)/rating")
        case .popular(let page, let lang, let region):
            return movies
                .appendingPathComponent("popular")
                .appendingPage(page)
                .appendingLanguage(lang)
                .appendingRegion(region)
        case .latest(let lang):
            return movies
                .appendingPathComponent("latest")
                .appendingLanguage(lang)
        case .topRated(let page, let lang, let region):
            return movies
                .appendingPathComponent("top_rated")
                .appendingPage(page)
                .appendingLanguage(lang)
                .appendingRegion(region)
        case .nowPlaying(let page, let lang, let region):
            return movies
                .appendingPathComponent("now_playing")
                .appendingPage(page)
                .appendingLanguage(lang)
                .appendingRegion(region)
        case .upcoming(let page, let lang, let region):
            return movies
                .appendingPathComponent("upcoming")
                .appendingPage(page)
                .appendingLanguage(lang)
                .appendingRegion(region)
        }
    }
}
