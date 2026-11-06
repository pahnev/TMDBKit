//
//  MovieEndpointTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import CoreFoundation
import XCTest
@testable import TMDBKit

class MovieEndpointTests: TMDBTestCase {

    func testPersonOnlyCreditsAreOmittedForMovieAndTV() throws {
        let appends: [DetailsAppendable] = [.movieCredits, .tvCredits, .combinedCredits]
        let app = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/movie/1", app) { tmdb.movies.details(for: 1, appending: appends, completion: $0) }
        try assertGETQuery("/3/tv/1", app) { tmdb.tv.details(for: 1, appending: appends, completion: $0) }
    }

    func testAppendLanguageHasSingleDeterministicValue() throws {
        let appends: [DetailsAppendable] = [.reviews(language: nil), .videos(language: "fi"), .reviews(language: "es"), .images(languages: ["en", "null"]), .images(languages: ["null", "fi"]), .credits, .credits]
        for explicit: String? in [nil, "de"] {
            let common = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: explicit ?? "fi"), URLQueryItem(name: "include_image_language", value: "en,null,fi")]
            try assertGETQuery("/3/movie/1", common + [URLQueryItem(name: "append_to_response", value: "reviews,videos,images,credits")]) {
                tmdb.movies.details(for: 1, appending: appends, language: explicit, completion: $0)
            }
            try assertGETQuery("/3/tv/1", common + [URLQueryItem(name: "append_to_response", value: "reviews,videos,images,credits")]) {
                tmdb.tv.details(for: 1, language: explicit, appending: appends, completion: $0)
            }
        }
        // Person rejects the language-bearing movie/TV resources; explicit language remains.
        try assertGETQuery("/3/person/1", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "de"), URLQueryItem(name: "include_image_language", value: "en,null,fi"), URLQueryItem(name: "append_to_response", value: "images,combined_credits")]) {
            tmdb.people.details(for: 1, language: "de", appending: appends, completion: $0)
        }
    }

    func testGuestAccountStatesAndRatingsUseGuestSessionOnly() throws {
        try checkSession(guest: "guest", expectedKey: "guest_session_id", expectedValue: "guest")
        tmdb = makeTMDB(authenticator: MockAuth(sessionId: nil))
        try checkSession(guest: "guest", expectedKey: "guest_session_id", expectedValue: "guest")
    }

    func testDefaultUserSessionRemainsCompatible() throws {
        try checkSession(guest: nil, expectedKey: "session_id", expectedValue: "456")
    }

    private func checkSession(guest: String?, expectedKey: String, expectedValue: String) throws {
        let credentials = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: expectedKey, value: expectedValue)]
        stubResponse(["id": 1, "favorite": true, "watchlist": false, "rated": ["value": 8.5]]) { request in
            try RequestExpectation(path: "/3/movie/1/account_states", query: ["api_key": "123", expectedKey: expectedValue]).assertRequest(request)
        }
        let state = try XCTUnwrap(awaitFor { tmdb.movies.accountStates(for: 1, guestSessionId: guest, completion: $0) }.value)
        XCTAssertEqual(state.id, 1)
        XCTAssertTrue(state.favorite)
        XCTAssertEqual(state.rated?.value, 8.5)
        for method in ["POST", "DELETE"] {
            var count = 0
            stubResponse(["status_code": 1, "status_message": "ok"]) { request in
                count += 1
                XCTAssertEqual(request.httpMethod, method)
                XCTAssertEqual(request.url?.path, "/3/movie/1/rating")
                XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json;charset=utf-8")
                let query = try self.queryItems(in: request)
                XCTAssertEqual(query.count, 2)
                for item in credentials { XCTAssertEqual(query.filter { $0 == item }.count, 1) }
                if method == "POST" {
                    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: self.requestBody(request)) as? [String: Double])
                    XCTAssertEqual(object, ["value": 8.5])
                } else { XCTAssertNil(request.httpBody) }
            }
            let response: StatusResponse?
            if method == "POST" { response = try awaitFor { tmdb.movies.rateMovie(1, rating: 8.5, guestSessionId: guest, completion: $0) }.value }
            else { response = try awaitFor { tmdb.movies.deleteRating(of: 1, guestSessionId: guest, completion: $0) }.value }
            XCTAssertEqual(response?.statusCode, 1)
            XCTAssertEqual(response?.statusMessage, "ok")
            XCTAssertEqual(count, 1)
        }
    }
    let blackPantherMovieId = 284054
    let allQuietMovieId = 143

    func testMovieVideosOnlyUseDocumentedLanguage() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/movie/1/videos", application) { tmdb.movies.videos(for: 1, completion: $0) }
        try assertGETQuery("/3/movie/1/videos", application + [URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.videos(for: 1, language: "fi-FI", completion: $0)
        }
    }

    func testImageLanguageFallbackQuery() throws {
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/movie/1/images", application) { tmdb.movies.images(for: 1, completion: $0) }
        try assertGETQuery("/3/movie/1/images", application) { tmdb.movies.images(for: 1, includeImageLanguages: nil, completion: $0) }
        try assertGETQuery("/3/movie/1/images", application + [URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "include_image_language", value: "en,null")]) {
            tmdb.movies.images(for: 1, language: "fi-FI", includeImageLanguages: ["en", "null"], completion: $0)
        }
        try assertGETQuery("/3/movie/1/images", application + [URLQueryItem(name: "include_image_language", value: "")]) {
            tmdb.movies.images(for: 1, includeImageLanguages: [], completion: $0)
        }
    }

    func testLegacyUndocumentedQueriesAreOmitted() throws {
        try assertGETQuery("/3/movie/latest", [URLQueryItem(name: "api_key", value: "123")]) {
            tmdb.movies.latest(language: "fi-FI", completion: $0)
        }
    }

    func testChangesForwardsDateRangeAndPage() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/3/movie/550/changes")
            let items = try self.queryItems(in: request)
            for (name, value) in [("page", "2"), ("start_date", "2026-11-01"), ("end_date", "2026-11-06")] {
                XCTAssertEqual(items.filter { $0.name == name }.map { $0.value }, [value])
            }
        }
        let result = try awaitFor {
            tmdb.movies.changes(for: 550, pageNumber: 2, startDate: "2026-11-01", endDate: "2026-11-06", completion: $0)
        }.value
        XCTAssertNotNil(result)
        XCTAssertEqual(requestCount, 1)
    }

    func testChangesOmitsUnspecifiedDates() throws {
        var requestCount = 0
        stubResponse(["changes": []]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/movie/550/changes")
            let items = try self.queryItems(in: request)
            XCTAssertEqual(items.filter { $0.name == "page" }.map { $0.value }, ["1"])
            XCTAssertFalse(items.contains { $0.name == "start_date" || $0.name == "end_date" })
        }
        XCTAssertNotNil(try awaitFor { tmdb.movies.changes(for: 550, completion: $0) }.value)
        XCTAssertEqual(requestCount, 1)
    }

    func testReturnsMovieDetails() throws {
        try stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: nil, language: nil), expecting: .init(path: "/3/movie/143"))

        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: nil, completion: $0) }.value

        XCTAssertNotNil(movie)
        XCTAssertEqual(movie?.id, 143)
        XCTAssertEqual(movie?.title, "All Quiet on the Western Front")
        XCTAssertEqual(movie?.imdbId, "tt0020629")
    }

    func testReturnsMovieDetailsWithAllExtraDetails() throws {
        try stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: DetailsAppendable.allCases, language: nil), expecting: .init(path: "/3/movie/143", query: ["api_key": "123", "append_to_response": "images,reviews,videos,credits,similar,recommendations,translations"]))
        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: DetailsAppendable.allCases, completion: $0) }.value

        XCTAssertNotNil(movie?.reviews)
        XCTAssertNotNil(movie?.videos)
        XCTAssertNotNil(movie?.images)
        XCTAssertNotNil(movie?.credits)
        XCTAssertNotNil(movie?.recommendations)
        XCTAssertNotNil(movie?.similar)
        XCTAssertNotNil(movie?.translations)
        XCTAssertEqual(movie?.id, 143)
        XCTAssertEqual(movie?.title, "All Quiet on the Western Front")
        XCTAssertEqual(movie?.imdbId, "tt0020629")
    }

    func testReturnsAccountsStatesForMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.accountStates(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/account_states", query: ["api_key": "123", "session_id": "456"]))

        let result = try awaitFor { tmdb.movies.accountStates(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 284054)
        XCTAssertNil(result?.rated)
        XCTAssertEqual(result?.id, 284054)
    }

    func testReturnsAccountsStatesForMovieWithRating() throws {
        try stubHelper.stubWithLocalFile(Movies.accountStates(movieId: allQuietMovieId), expecting: .init(path: "/3/movie/143/account_states", query: ["api_key": "123", "session_id": "456"]))

        let result = try awaitFor { tmdb.movies.accountStates(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.rated?.value, 3.0)
        XCTAssertEqual(result?.id, 580489)
    }

    func testReturnsAlternativeTitlesForMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.alternativeTitles(movieId: allQuietMovieId, country: nil), expecting: .init(path: "/3/movie/143/alternative_titles"))

        let alternatives = try awaitFor { tmdb.movies.alternativeTitles(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(alternatives)
        XCTAssertEqual(alternatives?.id, 143)
        XCTAssertEqual(alternatives?.titles.first?.title, "À l'Ouest, rien de nouveau")
    }

    func testReturnsChanges() throws {
        try stubHelper.stubWithLocalFile(Movies.changes(movieId: allQuietMovieId), expecting: .init(path: "/3/movie/143/changes", query: ["api_key": "123", "page": "1"]))

        let changes = try awaitFor { tmdb.movies.changes(for: allQuietMovieId, completion: $0) }.value

        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.changes?.count, 0)
    }

    func testReturnsCredits() throws {
        try stubHelper.stubWithLocalFile(Movies.credits(movieId: blackPantherMovieId, language: nil), expecting: .init(path: "/3/movie/284054/credits"))

        let credits = try awaitFor { tmdb.movies.credits(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(credits)
        XCTAssertEqual(credits?.id, 284054)
        XCTAssertEqual(credits?.cast.first?.name, "Chadwick Boseman")
    }

    func testReturnsExternalIds() throws {
        try stubHelper.stubWithLocalFile(Movies.externalIds(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/external_ids"))

        let ids = try awaitFor { tmdb.movies.externalIds(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(ids)
        XCTAssertEqual(ids?.id, 284054)
        XCTAssertEqual(ids?.imdbId, "tt1825683")
    }

    func testReturnsMovieImages() throws {
        try stubHelper.stubWithLocalFile(Movies.images(movieId: blackPantherMovieId, language: nil), expecting: .init(path: "/3/movie/284054/images"))

        let images = try awaitFor { tmdb.movies.images(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(images)
        XCTAssertEqual(images?.id, 284054)
        XCTAssertEqual(images?.backdrops.first?.filePath, "/6ELJEzQJ3Y45HczvreC3dg0GV5R.jpg")
    }

    func testReturnsKeywords() throws {
        try stubHelper.stubWithLocalFile(Movies.keywords(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/keywords"))

        let words = try awaitFor { tmdb.movies.keywords(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(words)
        XCTAssertEqual(words?.id, 284054)
        XCTAssertEqual(words?.keywords.first?.name, "africa")
    }

    func testReturnsReleaseDates() throws {
        try stubHelper.stubWithLocalFile(Movies.releaseDates(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/release_dates"))

        let dates = try awaitFor { tmdb.movies.releaseDates(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(dates)
        XCTAssertEqual(dates?.id, 284054)
        XCTAssertEqual(dates?.results.first?.iso31661, "LT")
    }

    func testReturnsVideos() throws {
        try stubHelper.stubWithLocalFile(Movies.videos(movieId: blackPantherMovieId, language: nil), expecting: .init(path: "/3/movie/284054/videos"))

        let videos = try awaitFor { tmdb.movies.videos(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(videos)
        XCTAssertEqual(videos?.id, 284054)
        XCTAssertEqual(videos?.results.first?.key, "xjDjIWPwcPU")
    }

    func testReturnsWatchProviders() throws {
        try stubHelper.stubWithLocalFile(Movies.watchProviders(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/watch/providers"))

        let providers = try awaitFor { tmdb.movies.watchProviders(for: blackPantherMovieId, completion: $0) }.value
        XCTAssertNotNil(providers)

        let finnishProviders = providers?.results?.fi
        XCTAssertEqual(finnishProviders?.link, "https://www.themoviedb.org/movie/284054-black-panther/watch?locale=FI")
        XCTAssertEqual(finnishProviders?.buy?.count, 8)
        XCTAssertEqual(finnishProviders?.rent?.count, 5)
        XCTAssertEqual(finnishProviders?.flatrate?.count, 1)
        XCTAssertEqual(providers?.id, 284054)
    }

    func testReturnsTranslations() throws {
        try stubHelper.stubWithLocalFile(Movies.translations(movieId: blackPantherMovieId), expecting: .init(path: "/3/movie/284054/translations"))

        let translations = try awaitFor { tmdb.movies.translations(for: blackPantherMovieId, completion: $0) }.value

        XCTAssertNotNil(translations)
        XCTAssertEqual(translations?.id, 284054)
        XCTAssertEqual(translations?.translations.first?.englishName, "Polish")
    }

    func testReturnsRecommendations() throws {
        try stubHelper.stubWithLocalFile(Movies.recommendations(movieId: blackPantherMovieId, pageNumber: 1, language: nil), expecting: .init(path: "/3/movie/284054/recommendations", query: ["api_key": "123", "page": "1"]))

        let movies = try awaitFor { tmdb.movies.recommendations(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
        XCTAssertEqual(movies?.page, 1)
        XCTAssertEqual(movies?.totalPages, 1)
        XCTAssertEqual(movies?.totalResults, 20)
        XCTAssertEqual(movies?.results.first?.id, 284053)
    }

    func testSimilarMoviesUsesCurrentRoute() {
        let url = Movies.similarMovies(movieId: 284054, pageNumber: 2, language: "fi-FI").url
        XCTAssertEqual(url.path, "/3/movie/284054/similar")
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
        XCTAssertTrue(query.contains(URLQueryItem(name: "page", value: "2")))
        XCTAssertTrue(query.contains(URLQueryItem(name: "language", value: "fi-FI")))
    }

    func testReturnsSimilarMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.similarMovies(movieId: blackPantherMovieId, pageNumber: 1, language: nil), expecting: .init(path: "/3/movie/284054/similar", query: ["api_key": "123", "page": "1"]))

        let movies = try awaitFor { tmdb.movies.similarMovies(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
        XCTAssertEqual(movies?.page, 1)
        XCTAssertEqual(movies?.totalPages, 63)
        XCTAssertEqual(movies?.totalResults, 1248)
        XCTAssertEqual(movies?.results.first?.id, 1924)
    }

    func testReturnsReviews() throws {
        try stubHelper.stubWithLocalFile(Movies.reviews(movieId: blackPantherMovieId, pageNumber: 1, language: nil), expecting: .init(path: "/3/movie/284054/reviews", query: ["api_key": "123", "page": "1"]))

        let reviews = try awaitFor { tmdb.movies.reviews(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(reviews)
        XCTAssertEqual(reviews?.id, 284054)
        XCTAssertEqual(reviews?.page, 1)
        XCTAssertEqual(reviews?.totalPages, 1)
        XCTAssertEqual(reviews?.totalResults, 16)
        XCTAssertEqual(reviews?.results.first?.id, "5a844e0fc3a36862e100c22f")
    }

    func testReturnsLists() throws {
        try stubHelper.stubWithLocalFile(Movies.lists(movieId: blackPantherMovieId, pageNumber: 1, language: nil), expecting: .init(path: "/3/movie/284054/lists", query: ["api_key": "123", "page": "1"]))

        let lists = try awaitFor { tmdb.movies.lists(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(lists)
        XCTAssertEqual(lists?.id, 284054)
        XCTAssertEqual(lists?.page, 1)
        XCTAssertEqual(lists?.totalPages, 42)
        XCTAssertEqual(lists?.totalResults, 838)
        XCTAssertEqual(lists?.results.first?.id, 46580)
    }

    func testReturnsNowPlayingMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil), expecting: .init(path: "/3/movie/now_playing", query: ["api_key": "123", "page": "1"]))

        let nowPlaying = try awaitFor { tmdb.movies.nowPlaying(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(nowPlaying)
        XCTAssertEqual(nowPlaying?.page, 1)
        XCTAssertEqual(nowPlaying?.totalPages, 52)
        XCTAssertEqual(nowPlaying?.totalResults, 1040)
        XCTAssertEqual(nowPlaying?.results.first?.id, 351286)
    }

    func testReturnsLatestMovie() throws {
        try stubHelper.stubWithLocalFile(Movies.latest(language: nil), expecting: .init(path: "/3/movie/latest"))

        let movie = try awaitFor { tmdb.movies.latest(completion: $0) }.value

        XCTAssertNotNil(movie)
        XCTAssertEqual(movie?.id, 533504)
        XCTAssertEqual(movie?.title, "Конец старой Березовки")
        XCTAssertEqual(movie?.imdbId, "tt2921084")
    }

    func testReturnsPopularMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.popular(pageNumber: 1, language: nil, region: nil), expecting: .init(path: "/3/movie/popular", query: ["api_key": "123", "page": "1"]))

        let movies = try awaitFor { tmdb.movies.popular(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
        XCTAssertEqual(movies?.page, 1)
        XCTAssertEqual(movies?.totalPages, 992)
        XCTAssertEqual(movies?.totalResults, 19833)
        XCTAssertEqual(movies?.results.first?.id, 351286)
    }

    func testReturnsTopRatedMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.topRated(pageNumber: 1, language: nil, region: nil), expecting: .init(path: "/3/movie/top_rated", query: ["api_key": "123", "page": "1"]))

        let movies = try awaitFor { tmdb.movies.topRated(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(movies)
        XCTAssertEqual(movies?.page, 1)
        XCTAssertEqual(movies?.totalPages, 378)
        XCTAssertEqual(movies?.totalResults, 7541)
        XCTAssertEqual(movies?.results.first?.id, 19404)
    }

    func testReturnsUpcomingMovies() throws {
        try stubHelper.stubWithLocalFile(Movies.upcoming(pageNumber: 1, language: nil, region: nil), expecting: .init(path: "/3/movie/upcoming", query: ["api_key": "123", "page": "1"]))

        let nowPlaying = try awaitFor { tmdb.movies.upcoming(pageNumber: 1, completion: $0) }.value

        XCTAssertNotNil(nowPlaying)
        XCTAssertEqual(nowPlaying?.page, 1)
        XCTAssertEqual(nowPlaying?.totalPages, 12)
        XCTAssertEqual(nowPlaying?.totalResults, 240)
        XCTAssertEqual(nowPlaying?.results.first?.id, 351286)
    }

    func testEndpointURLsAreConstructedProperly() throws {
        assertURL(.accountStates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/account_states")

        assertURL(.alternativeTitles(movieId: 1, country: "fi"), matches: "https://api.themoviedb.org/3/movie/1/alternative_titles?country=fi")

        assertURL(.changes(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/changes?page=1")

        assertURL(.credits(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/credits?language=fi")

        assertURL(.deleteRating(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.details(movieId: 1, append: nil, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1?language=fi")

        assertURL(.externalIds(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/external_ids")

        assertURL(.images(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/images?language=fi")

        assertURL(.keywords(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/keywords")

        assertURL(.latest(language: "fi"), matches: "https://api.themoviedb.org/3/movie/latest")

        assertURL(.lists(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/lists?page=1&language=fi")

        assertURL(.nowPlaying(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/now_playing?page=1&language=fi&region=fi")

        assertURL(.popular(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/popular?page=1&language=fi&region=fi")

        assertURL(.rateMovie(rating: 1, movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.recommendations(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/recommendations?page=1&language=fi")

        assertURL(.releaseDates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/release_dates")

        assertURL(.reviews(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/reviews?page=1&language=fi")

        assertURL(.similarMovies(movieId: 1, pageNumber: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/similar?page=1&language=fi")

        assertURL(.topRated(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/top_rated?page=1&language=fi&region=fi")

        assertURL(.translations(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/translations")

        assertURL(.upcoming(pageNumber: 1, language: "fi", region: "fi"), matches: "https://api.themoviedb.org/3/movie/upcoming?page=1&language=fi&region=fi")

        assertURL(.videos(movieId: 1, language: "fi"), matches: "https://api.themoviedb.org/3/movie/1/videos?language=fi")
    }

    func testDetailsEndpointURLAppendsDetails() throws {
        let credits = Movies.details(movieId: 1, append: [DetailsAppendable.credits], language: nil)
        assertURL(credits, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=credits")

        let creditsWithLang = Movies.details(movieId: 1, append: [DetailsAppendable.credits], language: "fi")
        assertURL(creditsWithLang, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=credits")

        let similar = Movies.details(movieId: 1, append: [DetailsAppendable.similar], language: nil)
        assertURL(similar, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=similar")

        let recommendations = Movies.details(movieId: 1, append: [DetailsAppendable.recommendations], language: "fi")
        assertURL(recommendations, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=recommendations")

        let translations = Movies.details(movieId: 1, append: [DetailsAppendable.translations], language: "fi")
        assertURL(translations, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=translations")

        let reviews = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: nil)], language: "fi")
        assertURL(reviews, matches: "https://api.themoviedb.org/3/movie/1?language=fi&append_to_response=reviews")

        let reviews2 = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: "en")], language: nil)
        assertURL(reviews2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=reviews&language=en")

        let videos = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: nil)], language: nil)
        assertURL(videos, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos")

        let videos2 = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: "en")], language: nil)
        assertURL(videos2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos&language=en")

        let images = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: nil)], language: nil)
        assertURL(images, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images")

        let images2 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en"])], language: nil)
        assertURL(images2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en")

        let images3 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en", "fi"])], language: nil)
        assertURL(images3, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en,fi")
    }

    func test_httpMethod() {
        // Verify http method for each case
        XCTAssertEqual(Movies.accountStates(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.alternativeTitles(movieId: 1, country: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.changes(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.credits(movieId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.deleteRating(movieId: 1).httpMethod, .DELETE)
        XCTAssertEqual(Movies.details(movieId: 1, append: nil, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.externalIds(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.images(movieId: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.keywords(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.latest(language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.lists(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.popular(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.rateMovie(rating: 1, movieId: 1).httpMethod, .POST)
        XCTAssertEqual(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.releaseDates(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.topRated(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.translations(movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Movies.upcoming(pageNumber: 1, language: nil, region: nil).httpMethod, .GET)
        XCTAssertEqual(Movies.videos(movieId: 1, language: nil).httpMethod, .GET)
    }

    func test_httpBody() {
        // Verify http body for each case
        XCTAssertNil(Movies.accountStates(movieId: 1).httpBody)
        XCTAssertNil(Movies.alternativeTitles(movieId: 1, country: nil).httpBody)
        XCTAssertNil(Movies.changes(movieId: 1).httpBody)
        XCTAssertNil(Movies.credits(movieId: 1, language: nil).httpBody)
        XCTAssertNil(Movies.deleteRating(movieId: 1).httpBody)
        XCTAssertNil(Movies.details(movieId: 1, append: nil, language: nil).httpBody)
        XCTAssertNil(Movies.externalIds(movieId: 1).httpBody)
        XCTAssertNil(Movies.images(movieId: 1, language: nil).httpBody)
        XCTAssertNil(Movies.keywords(movieId: 1).httpBody)
        XCTAssertNil(Movies.latest(language: nil).httpBody)
        XCTAssertNil(Movies.lists(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.popular(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.releaseDates(movieId: 1).httpBody)
        XCTAssertNil(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).httpBody)
        XCTAssertNil(Movies.topRated(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.translations(movieId: 1).httpBody)
        XCTAssertNil(Movies.upcoming(pageNumber: 1, language: nil, region: nil).httpBody)
        XCTAssertNil(Movies.videos(movieId: 1, language: nil).httpBody)
    }

    func test_rateMovie_httpBody() throws {
        let body = try XCTUnwrap(Movies.rateMovie(rating: 1, movieId: 1).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["value"]))
        let number = try XCTUnwrap(object["value"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
        XCTAssertEqual(number.doubleValue, 1)
    }

    func test_requestHeaders() {
        // Verify request headers for each case
        XCTAssertEqual(Movies.accountStates(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.alternativeTitles(movieId: 1, country: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.changes(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.credits(movieId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.details(movieId: 1, append: nil, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.externalIds(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.images(movieId: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.keywords(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.latest(language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.lists(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.nowPlaying(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.popular(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.recommendations(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.releaseDates(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.reviews(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.similarMovies(movieId: 1, pageNumber: 1, language: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.topRated(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.translations(movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Movies.upcoming(pageNumber: 1, language: nil, region: nil).requestHeaders, [:])
        XCTAssertEqual(Movies.videos(movieId: 1, language: nil).requestHeaders, [:])

        let expectedHeaders = ["Content-Type": "application/json;charset=utf-8"]
        XCTAssertEqual(Movies.deleteRating(movieId: 1).requestHeaders, expectedHeaders)
        XCTAssertEqual(Movies.rateMovie(rating: 1, movieId: 1).requestHeaders, expectedHeaders)
    }

    private func assertURL(_ endpoint: Movies, matches expectedValue: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(endpoint.url.absoluteString, expectedValue, file: file, line: line)
    }
}

extension MovieEndpointTests {
    func testAppendQueriesPreserveLanguageAndPage() throws {
        // Details has no root page argument. Appended review pagination belongs to the response.
        var object = try contractObject("movie-details")
        var reviews = try contractObject("movie-reviews", omitID: true)
        reviews["page"] = 2
        reviews["total_pages"] = 7
        reviews["total_results"] = 121
        object["reviews"] = reviews
        stubResponse(object) { request in
            try RequestExpectation(path: "/3/movie/11", query: ["api_key": "123", "language": "fi-FI", "append_to_response": "reviews,videos,images", "include_image_language": "fi,en,null"]).assertRequest(request)
        }
        let movie = try XCTUnwrap(awaitFor { tmdb.movies.details(for: 11, appending: [.reviews(language: "fi-FI"), .videos(language: "fi-FI"), .images(languages: ["fi", "en", "null"])], language: "fi-FI", completion: $0) }.value)
        XCTAssertEqual(movie.id, 11)
        XCTAssertEqual(movie.reviews?.page, 2)
        XCTAssertEqual(movie.reviews?.totalPages, 7)
        XCTAssertEqual(movie.reviews?.totalResults, 121)
        XCTAssertEqual(movie.reviews?.results.first?.author, "Goddard")
    }
}

extension MovieEndpointTests {
    func testnowPlayingNondefaultOptions() throws {
        try assertGETQuery("/3/movie/now_playing", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "region", value: "FI")]) {
            tmdb.movies.nowPlaying(pageNumber: 2, language: "fi-FI", region: "FI", completion: $0)
        }
    }

    func testpopularNondefaultOptions() throws {
        try assertGETQuery("/3/movie/popular", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "region", value: "FI")]) {
            tmdb.movies.popular(pageNumber: 2, language: "fi-FI", region: "FI", completion: $0)
        }
    }

    func testtopRatedNondefaultOptions() throws {
        try assertGETQuery("/3/movie/top_rated", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "region", value: "FI")]) {
            tmdb.movies.topRated(pageNumber: 2, language: "fi-FI", region: "FI", completion: $0)
        }
    }

    func testupcomingNondefaultOptions() throws {
        try assertGETQuery("/3/movie/upcoming", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI"), URLQueryItem(name: "region", value: "FI")]) {
            tmdb.movies.upcoming(pageNumber: 2, language: "fi-FI", region: "FI", completion: $0)
        }
    }

    func testlistsNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/lists", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.lists(for: 550, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testrecommendationsNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/recommendations", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.recommendations(for: 550, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testreviewsNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/reviews", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.reviews(for: 550, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testsimilarMoviesNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/similar", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.similarMovies(for: 550, pageNumber: 2, language: "fi-FI", completion: $0)
        }
    }

    func testAlternativeTitlesNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/alternative_titles", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "country", value: "FI")]) {
            tmdb.movies.alternativeTitles(for: 550, country: "FI", completion: $0)
        }
    }

    func testCreditsNondefaultOptions() throws {
        try assertGETQuery("/3/movie/550/credits", [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.movies.credits(for: 550, language: "fi-FI", completion: $0)
        }
    }

}

extension MovieEndpointTests {
    func testOriginalRatingOverloadsReturnStatus() throws {
        let rate = tmdb.movies.rateMovie(_:rating:completion:)
        let delete = tmdb.movies.deleteRating(of:completion:)
        stubResponse(["status_code": 1, "status_message": "Created."]) { request in
            try RequestExpectation(path: "/3/movie/1/rating", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["value": 8.5], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let rated = try XCTUnwrap(awaitFor { rate(1, 8.5, $0) }.value)
        XCTAssertEqual(rated.statusCode, 1)
        XCTAssertEqual(rated.statusMessage, "Created.")
        stubResponse(["status_code": 13, "status_message": "Deleted."]) { request in
            try RequestExpectation(path: "/3/movie/1/rating", method: "DELETE", query: ["api_key": "123", "session_id": "456"], contentType: "application/json;charset=utf-8").assertRequest(request)
        }
        let deleted = try XCTUnwrap(awaitFor { delete(1, $0) }.value)
        XCTAssertEqual(deleted.statusCode, 13)
        XCTAssertEqual(deleted.statusMessage, "Deleted.")
    }
}
