//
//  Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 30/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum Movies: Endpoint {

    case accountStates(movieId: Int, sessionsId: String)

    case alternativeTitles(movieId: Int)

    case changes(movieId: Int)

    case credits(movieId: Int)

    case deleteRating(movieId: Int, sessionId: String)

    /// Get the most newly created movie. This is a live response and will continuously change.
    /// Get the primary information about a movie
    case details(movieId: Int, append: [DetailsAppendable]?)

    case externalIds(movieId: Int)

    case images(movieId: Int)

    case keywords(movieId: Int)

    case latest

    /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
    case lists(movieId: Int, pageNumber: PageNumber)

    case nowPlaying(pageNumber: PageNumber)

    /// Get a list of the current popular movies on TMDb. This list updates daily.
    case popular(pageNumber: PageNumber)

    /// Get the top rated movies on TMDb.
    case rateMovie(rating: Double, movieId: Int, sessionId: String)

    case recommendations(movieId: Int, pageNumber: PageNumber)

    case releaseDates(movieId: Int)

    case reviews(movieId: Int, pageNumber: PageNumber)

    case similarMovies(movieId: Int, pageNumber: PageNumber)

    case topRated(pageNumber: PageNumber)

    /// Get a list of upcoming movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.

    /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
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
        case .rateMovie(let params):
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
        guard let baseURL = URL(string: "https://api.themoviedb.org/3/") else {
            preconditionFailure("Invalid URL string")
        }
        let movies = baseURL.appendingPathComponent("movie")

        switch self {
        case .details(let params):
            let movieDetails = movies.appendingPathComponent("\(params.movieId)")
            if let append = params.append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return movieDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return movieDetails
        case .accountStates(let params):
            return movies.appendingPathComponent("\(params.movieId)/account_states")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionsId))
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
        case .recommendations(let params):
            return movies.appendingPathComponent("\(params.movieId)/recommendations")
        case .similarMovies(let params):
            return movies.appendingPathComponent("\(params.movieId)/similar_movies")
        case .reviews(let params):
            return movies.appendingPathComponent("\(params.movieId)/reviews")
        case .lists(let params):
            return movies.appendingPathComponent("\(params.movieId)/lists")
        case .rateMovie(let params):
            return movies.appendingPathComponent("\(params.movieId)/rating")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionId))
        case .deleteRating(let params):
            return movies.appendingPathComponent("\(params.movieId)/rating")
                .appendingQueryItem(URLQueryItem(name: "session_id", value: params.sessionId))
        case .popular:
            return movies.appendingPathComponent("popular")
        case .latest:
            return movies.appendingPathComponent("latest")
        case .topRated:
            return movies.appendingPathComponent("top_rated")
        case .nowPlaying:
            return movies.appendingPathComponent("now_playing")
        case .upcoming:
            return movies.appendingPathComponent("upcoming")

        }
    }

}
