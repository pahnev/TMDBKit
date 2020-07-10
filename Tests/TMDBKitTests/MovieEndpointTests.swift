//
//  TMDBKitTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import XCTest
import Nimble
@testable import TMDBKit

class MovieEndpointTests: TMDBTestCase {

    let blackPantherMovieId = 284054
    let allQuietMovieId = 143

    func testReturnsMovieDetails() {
        stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: nil))

        var movie: Movie?
        tmdb.movies.details(for: allQuietMovieId, appending: nil) { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsMovieDetailsWithAllExtraDetails() {
        stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: DetailsAppendable.allCases))
        var movie: Movie?
        tmdb.movies.details(for: allQuietMovieId, appending: DetailsAppendable.allCases) { result in
            movie = result.value
        }
        expect(movie?.reviews).toEventuallyNot(beNil())
        expect(movie?.videos).toEventuallyNot(beNil())
        expect(movie?.images).toEventuallyNot(beNil())
        expect(movie?.credits).toEventuallyNot(beNil())
        expect(movie?.recommendations).toEventuallyNot(beNil())
        expect(movie?.similar).toEventuallyNot(beNil())
        expect(movie?.translations).toEventuallyNot(beNil())
    }

    func testReturnsAlternativeTitlesForMovie() {
        stubHelper.stubWithLocalFile(Movies.alternativeTitles(movieId: allQuietMovieId))

        var alternatives: AlternativeTitlesResponse?
        tmdb.movies.alternativeTitles(for: allQuietMovieId) { result in
            alternatives = result.value
        }
        expect(alternatives).toEventuallyNot(beNil())
    }

    func testReturnsChanges() {
        stubHelper.stubWithLocalFile(Movies.changes(movieId: allQuietMovieId))

        var changes: ChangesResponse?
        tmdb.movies.changes(for: allQuietMovieId) { result in
            changes = result.value
        }
        expect(changes).toEventuallyNot(beNil())
    }

    func testReturnsCredits() {
        stubHelper.stubWithLocalFile(Movies.credits(movieId: blackPantherMovieId))

        var credits: CreditsResponse?
        tmdb.movies.credits(for: blackPantherMovieId) { result in
            credits = result.value
        }
        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() {
        stubHelper.stubWithLocalFile(Movies.externalIds(movieId: blackPantherMovieId))

        var ids: ExternalIds?
        tmdb.movies.externalIds(for: blackPantherMovieId) { result in
            ids = result.value
        }
        expect(ids).toEventuallyNot(beNil())
    }

    func testReturnsMovieImages() {
        stubHelper.stubWithLocalFile(Movies.images(movieId: blackPantherMovieId))

        var images: ImagesResponse?
        tmdb.movies.images(for: blackPantherMovieId) { result in
            images = result.value
        }
        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsKeywords() {
        stubHelper.stubWithLocalFile(Movies.keywords(movieId: blackPantherMovieId))

        var words: KeywordsResponse?
        tmdb.movies.keywords(for: blackPantherMovieId) { result in
            words = result.value
        }
        expect(words).toEventuallyNot(beNil())
    }

    func testReturnsReleaseDates() {
        stubHelper.stubWithLocalFile(Movies.releaseDates(movieId: blackPantherMovieId))

        var dates: ReleaseDatesResponse?
        tmdb.movies.releaseDates(for: blackPantherMovieId) { result in
            dates = result.value
        }
        expect(dates).toEventuallyNot(beNil())
    }

    func testReturnsVideos() {
        stubHelper.stubWithLocalFile(Movies.videos(movieId: blackPantherMovieId))

        var videos: VideosResponse?
        tmdb.movies.videos(for: blackPantherMovieId) { result in
            videos = result.value
        }
        expect(videos).toEventuallyNot(beNil())
    }

    func testReturnsTranslations() {
        stubHelper.stubWithLocalFile(Movies.translations(movieId: blackPantherMovieId))

        var translations: TranslationsResponse?
        tmdb.movies.translations(for: blackPantherMovieId) { result in
            translations = result.value
        }
        expect(translations).toEventuallyNot(beNil())
    }

    func testReturnsRecommendations() {
        stubHelper.stubWithLocalFile(Movies.recommendations(movieId: blackPantherMovieId, pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.movies.recommendations(for: blackPantherMovieId, pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsSimilarMovies() {
        stubHelper.stubWithLocalFile(Movies.similarMovies(movieId: blackPantherMovieId, pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.movies.similarMovies(for: blackPantherMovieId, pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsReviews() {
        stubHelper.stubWithLocalFile(Movies.reviews(movieId: blackPantherMovieId, pageNumber: 1))

        var reviews: ReviewsResponse?
        tmdb.movies.reviews(for: blackPantherMovieId, pageNumber: 1) { result in
            reviews = result.value
        }
        expect(reviews).toEventuallyNot(beNil())
    }

    func testReturnsLists() {
        stubHelper.stubWithLocalFile(Movies.lists(movieId: blackPantherMovieId, pageNumber: 1))

        var lists: ListsResponse?
        tmdb.movies.lists(for: blackPantherMovieId, pageNumber: 1) { result in
            lists = result.value
        }
        expect(lists).toEventuallyNot(beNil())
    }

    func testReturnsNowPlayingMovies() {
        stubHelper.stubWithLocalFile(Movies.nowPlaying(pageNumber: 1))

        var nowPlaying: NowPlayingMoviesResponse?
        tmdb.movies.nowPlaying(pageNumber: 1) { result in
            nowPlaying = result.value
        }
        expect(nowPlaying).toEventuallyNot(beNil())
    }

    func testReturnsLatestMovie() {
        stubHelper.stubWithLocalFile(Movies.latest)

        var movie: Movie?
        tmdb.movies.latest { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsPopularMovies() {
        stubHelper.stubWithLocalFile(Movies.popular(pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.movies.popular(pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsTopRatedMovies() {
        stubHelper.stubWithLocalFile(Movies.topRated(pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.movies.topRated(pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsUpcomingMovies() {
        stubHelper.stubWithLocalFile(Movies.upcoming(pageNumber: 1))

        var nowPlaying: NowPlayingMoviesResponse?
        tmdb.movies.upcoming(pageNumber: 1) { result in
            nowPlaying = result.value
        }
        expect(nowPlaying).toEventuallyNot(beNil())

    }

    func testEndpointURLsAreConstructedProperly() {
        assertURL(.accountStates(movieId: 1, sessionsId: "id"), matches: "https://api.themoviedb.org/3/movie/1/account_states?session_id=id")

        assertURL(.alternativeTitles(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/alternative_titles")

        assertURL(.changes(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/changes")

        assertURL(.credits(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/credits")

        assertURL(.deleteRating(movieId: 1, sessionId: "id"), matches: "https://api.themoviedb.org/3/movie/1/rating?session_id=id")

        assertURL(.details(movieId: 1, append: nil), matches: "https://api.themoviedb.org/3/movie/1")

        assertURL(.externalIds(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/external_ids")

        assertURL(.images(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/images")

        assertURL(.keywords(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/keywords")

        assertURL(.latest, matches: "https://api.themoviedb.org/3/movie/latest")

        assertURL(.lists(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/lists?page=1")

        assertURL(.nowPlaying(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/now_playing?page=1")

        assertURL(.popular(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/popular?page=1")

        assertURL(.rateMovie(rating: 1, movieId: 1, sessionId: "id"), matches: "https://api.themoviedb.org/3/movie/1/rating?session_id=id")

        assertURL(.recommendations(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/recommendations?page=1")

        assertURL(.releaseDates(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/release_dates")

        assertURL(.reviews(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/reviews?page=1")

        assertURL(.similarMovies(movieId: 1, pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/1/similar_movies?page=1")

        assertURL(.topRated(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/top_rated?page=1")

        assertURL(.translations(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/translations")

        assertURL(.upcoming(pageNumber: 1), matches: "https://api.themoviedb.org/3/movie/upcoming?page=1")

        assertURL(.videos(movieId: 1), matches: "https://api.themoviedb.org/3/movie/1/videos")
    }

    func testDetailsEndpointURLAppendsDetails() {
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
