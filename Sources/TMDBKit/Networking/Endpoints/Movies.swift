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

    case alternativeTitles(movieId: Int)

    case changes(movieId: Int)

    case credits(movieId: Int)

    case deleteRating(movieId: Int)

    /// Get the most newly created movie. This is a live response and will continuously change.
    /// Get the primary information about a movie
    case details(movieId: Int, append: [DetailsAppendable]?)

    case externalIds(movieId: Int)

    case images(movieId: Int)

    case keywords(movieId: Int)

    case latest

    /// Get a list of movies in theaters. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region parameter which will narrow the search to only look for theatrical release dates within the specified country.
    case lists(movieId: Int, pageNumber: PageNumber)

    case nowPlaying(pageNumber: PageNumber)

    /// Get a list of the current popular movies on TMDb. This list updates daily.
    case popular(pageNumber: PageNumber)

    /// Get the top rated movies on TMDb.
    case rateMovie(rating: Double, movieId: Int)

    case recommendations(movieId: Int, pageNumber: PageNumber)

    case releaseDates(movieId: Int)

    case reviews(movieId: Int, pageNumber: PageNumber)

    case similarMovies(movieId: Int, pageNumber: PageNumber)

    case topRated(pageNumber: PageNumber)

    /// Get a list of upcoming movies in theaters. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region parameter which will narrow the search to only look for theatrical release dates within the specified country.
    case translations(movieId: Int)

    case upcoming(pageNumber: PageNumber)
    case videos(movieId: Int)


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
        case .details(let movieId, let append):
            let movieDetails = movies.appendingPathComponent("\(movieId)")
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
        case .alternativeTitles(let movieId):
            return movies.appendingPathComponent("\(movieId)/alternative_titles")
        case .changes(let movieId):
            return movies.appendingPathComponent("\(movieId)/changes")
        case .credits(let movieId):
            return movies.appendingPathComponent("\(movieId)/credits")
        case .externalIds(let movieId):
            return movies.appendingPathComponent("\(movieId)/external_ids")
        case .images(let movieId):
            return movies.appendingPathComponent("\(movieId)/images")
        case .keywords(let movieId):
            return movies.appendingPathComponent("\(movieId)/keywords")
        case .releaseDates(let movieId):
            return movies.appendingPathComponent("\(movieId)/release_dates")
        case .videos(let movieId):
            return movies.appendingPathComponent("\(movieId)/videos")
        case .translations(let movieId):
            return movies.appendingPathComponent("\(movieId)/translations")
        case .recommendations(let movieId, let page):
            return movies
                .appendingPathComponent("\(movieId)/recommendations")
                .appendingPage(page)
        case .similarMovies(let movieId, let page):
            return movies
                .appendingPathComponent("\(movieId)/similar_movies")
                .appendingPage(page)
        case .reviews(let movieId, let page):
            return movies
                .appendingPathComponent("\(movieId)/reviews")
                .appendingPage(page)
        case .lists(let movieId, let page):
            return movies
                .appendingPathComponent("\(movieId)/lists")
                .appendingPage(page)
        case .rateMovie(_, let movieId):
            return movies.appendingPathComponent("\(movieId)/rating")
        case .deleteRating(let movieId):
            return movies.appendingPathComponent("\(movieId)/rating")
        case .popular(let page):
            return movies.appendingPathComponent("popular").appendingPage(page)
        case .latest:
            return movies.appendingPathComponent("latest")
        case .topRated(let page):
            return movies.appendingPathComponent("top_rated").appendingPage(page)
        case .nowPlaying(let page):
            return movies.appendingPathComponent("now_playing").appendingPage(page)
        case .upcoming(let page):
            return movies.appendingPathComponent("upcoming").appendingPage(page)

        }
    }

}
