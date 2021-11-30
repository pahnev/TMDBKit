//
//  TMDBKitTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Nimble
import XCTest
@testable import TMDBKit

class MovieEndpointTests: TMDBTestCase {
    let blackPantherMovieId = 284054
    let allQuietMovieId = 143

    func testReturnsMovieDetails() throws {
        stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: nil))

        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: nil, completion: $0) }.value

        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsMovieDetailsWithAllExtraDetails() throws {
        stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: DetailsAppendable.allCases))
        let movie = try awaitFor { tmdb.movies.details(for: allQuietMovieId, appending: DetailsAppendable.allCases, completion: $0) }.value

        expect(movie?.reviews).toEventuallyNot(beNil())
        expect(movie?.videos).toEventuallyNot(beNil())
        expect(movie?.images).toEventuallyNot(beNil())
        expect(movie?.credits).toEventuallyNot(beNil())
        expect(movie?.recommendations).toEventuallyNot(beNil())
        expect(movie?.similar).toEventuallyNot(beNil())
        expect(movie?.translations).toEventuallyNot(beNil())
    }

    func testReturnsAlternativeTitlesForMovie() throws {
        stubHelper.stubWithLocalFile(Movies.alternativeTitles(movieId: allQuietMovieId))

        let alternatives = try awaitFor { tmdb.movies.alternativeTitles(for: allQuietMovieId, completion: $0) }.value

        expect(alternatives).toEventuallyNot(beNil())
    }

    func testReturnsChanges() throws {
        stubHelper.stubWithLocalFile(Movies.changes(movieId: allQuietMovieId))

        let changes = try awaitFor { tmdb.movies.changes(for: allQuietMovieId, completion: $0) }.value

        expect(changes).toEventuallyNot(beNil())
    }

    func testReturnsCredits() throws {
        stubHelper.stubWithLocalFile(Movies.credits(movieId: blackPantherMovieId))

        let credits = try awaitFor { tmdb.movies.credits(for: blackPantherMovieId, completion: $0) }.value

        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() throws {
        stubHelper.stubWithLocalFile(Movies.externalIds(movieId: blackPantherMovieId))

        let ids = try awaitFor { tmdb.movies.externalIds(for: blackPantherMovieId, completion: $0) }.value

        expect(ids).toEventuallyNot(beNil())
    }

    func testReturnsMovieImages() throws {
        stubHelper.stubWithLocalFile(Movies.images(movieId: blackPantherMovieId))

        let images = try awaitFor { tmdb.movies.images(for: blackPantherMovieId, completion: $0) }.value

        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsKeywords() throws {
        stubHelper.stubWithLocalFile(Movies.keywords(movieId: blackPantherMovieId))

        let words = try awaitFor { tmdb.movies.keywords(for: blackPantherMovieId, completion: $0) }.value

        expect(words).toEventuallyNot(beNil())
    }

    func testReturnsReleaseDates() throws {
        stubHelper.stubWithLocalFile(Movies.releaseDates(movieId: blackPantherMovieId))

        let dates = try awaitFor { tmdb.movies.releaseDates(for: blackPantherMovieId, completion: $0) }.value

        expect(dates).toEventuallyNot(beNil())
    }

    func testReturnsVideos() throws {
        stubHelper.stubWithLocalFile(Movies.videos(movieId: blackPantherMovieId))

        let videos = try awaitFor { tmdb.movies.videos(for: blackPantherMovieId, completion: $0) }.value

        expect(videos).toEventuallyNot(beNil())
    }

    func testReturnsTranslations() throws {
        stubHelper.stubWithLocalFile(Movies.translations(movieId: blackPantherMovieId))

        let translations = try awaitFor { tmdb.movies.translations(for: blackPantherMovieId, completion: $0) }.value

        expect(translations).toEventuallyNot(beNil())
    }

    func testReturnsRecommendations() throws {
        stubHelper.stubWithLocalFile(Movies.recommendations(movieId: blackPantherMovieId, pageNumber: 1))

        let movies = try awaitFor { tmdb.movies.recommendations(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsSimilarMovies() throws {
        stubHelper.stubWithLocalFile(Movies.similarMovies(movieId: blackPantherMovieId, pageNumber: 1))

        let movies = try awaitFor { tmdb.movies.similarMovies(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsReviews() throws {
        stubHelper.stubWithLocalFile(Movies.reviews(movieId: blackPantherMovieId, pageNumber: 1))

        let reviews = try awaitFor { tmdb.movies.reviews(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        expect(reviews).toEventuallyNot(beNil())
    }

    func testReturnsLists() throws {
        stubHelper.stubWithLocalFile(Movies.lists(movieId: blackPantherMovieId, pageNumber: 1))

        let lists = try awaitFor { tmdb.movies.lists(for: blackPantherMovieId, pageNumber: 1, completion: $0) }.value

        expect(lists).toEventuallyNot(beNil())
    }

    func testReturnsNowPlayingMovies() throws {
        stubHelper.stubWithLocalFile(Movies.nowPlaying(pageNumber: 1))

        let nowPlaying = try awaitFor { tmdb.movies.nowPlaying(pageNumber: 1, completion: $0) }.value

        expect(nowPlaying).toEventuallyNot(beNil())
    }

    func testReturnsLatestMovie() throws {
        stubHelper.stubWithLocalFile(Movies.latest)

        let movie = try awaitFor { tmdb.movies.latest(completion: $0) }.value

        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsPopularMovies() throws {
        stubHelper.stubWithLocalFile(Movies.popular(pageNumber: 1))

        let movies = try awaitFor { tmdb.movies.popular(pageNumber: 1, completion: $0) }.value

        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsTopRatedMovies() throws {
        stubHelper.stubWithLocalFile(Movies.topRated(pageNumber: 1))

        let movies = try awaitFor { tmdb.movies.topRated(pageNumber: 1, completion: $0) }.value

        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsUpcomingMovies() throws {
        stubHelper.stubWithLocalFile(Movies.upcoming(pageNumber: 1))

        let nowPlaying = try awaitFor { tmdb.movies.upcoming(pageNumber: 1, completion: $0) }.value

        expect(nowPlaying).toEventuallyNot(beNil())
    }

    func testEndpointURLsAreConstructedProperly() throws {
        assertURL(.accountStates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/account_states")

        assertURL(.alternativeTitles(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/alternative_titles")

        assertURL(.changes(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/changes")

        assertURL(.credits(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/credits")

        assertURL(.deleteRating(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.details(movieId: 1, append: nil), matches: "https://api.themoviedb.org/3/movie/1")

        assertURL(.externalIds(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/external_ids")

        assertURL(.images(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/images")

        assertURL(.keywords(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/keywords")

        assertURL(.latest, matches: "https://api.themoviedb.org/3/movie/latest")

        assertURL(.lists(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/lists?page=1")

        assertURL(.nowPlaying(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/now_playing?page=1")

        assertURL(.popular(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/popular?page=1")

        assertURL(.rateMovie(rating: 1, movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/rating")

        assertURL(.recommendations(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/recommendations?page=1")

        assertURL(.releaseDates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/release_dates")

        assertURL(.reviews(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/reviews?page=1")

        assertURL(.similarMovies(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/similar_movies?page=1")

        assertURL(.topRated(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/top_rated?page=1")

        assertURL(.translations(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/translations")

        assertURL(.upcoming(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/upcoming?page=1")

        assertURL(.videos(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/videos")
    }

    func testDetailsEndpointURLAppendsDetails() throws {
        let credits = Movies.details(movieId: 1, append: [DetailsAppendable.credits])
        assertURL(credits, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=credits")

        let similar = Movies.details(movieId: 1, append: [DetailsAppendable.similar])
        assertURL(similar, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=similar")

        let recommendations = Movies.details(movieId: 1, append: [DetailsAppendable.recommendations])
        assertURL(recommendations, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=recommendations")

        let translations = Movies.details(movieId: 1, append: [DetailsAppendable.translations])
        assertURL(translations, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=translations")

        let reviews = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: nil)])
        assertURL(reviews, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=reviews")

        let reviews2 = Movies.details(movieId: 1, append: [DetailsAppendable.reviews(language: "en")])
        assertURL(reviews2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=reviews&language=en")

        let videos = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: nil)])
        assertURL(videos, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos")

        let videos2 = Movies.details(movieId: 1, append: [DetailsAppendable.videos(language: "en")])
        assertURL(videos2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=videos&language=en")

        let images = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: nil)])
        assertURL(images, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images")

        let images2 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en"])])
        assertURL(images2, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en")

        let images3 = Movies.details(movieId: 1, append: [DetailsAppendable.images(languages: ["en", "fi"])])
        assertURL(images3, matches: "https://api.themoviedb.org/3/movie/1?append_to_response=images&include_image_language=en,fi")
    }

    private func assertURL(_ endpoint: Movies, matches expectedValue: String, file: FileString = #file, line: UInt = #line) {
        XCTAssertEqual(endpoint.url.absoluteString, expectedValue, file: file, line: line)
    }
}
