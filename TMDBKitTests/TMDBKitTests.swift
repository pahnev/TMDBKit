//
//  TMDBKitTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import TMDBKit

struct MockAuth: Authenticator {
    var apiKey: String {
        return "123"
    }
    var sessionId: String? {
        return nil
    }
}

class TMDBKitTests: XCTestCase {

    let mockAuth = MockAuth()
    let stubHelper = StubHelper()
    var tmdb: TMDB!

    let blackPantherMovieId = 284054
    let allQuietMovieId = 143
    
    override func setUp() {
        guard let tmdb = try? TMDB(authenticator: mockAuth) else { preconditionFailure() }
        self.tmdb = tmdb
        super.setUp()
    }
    
    override func tearDown() {
        tmdb.clearCaches()
        super.tearDown()
    }

    func testReturnsMovieDetails() {
        stubHelper.stubWithLocalFile(Movies.details(movieId: allQuietMovieId, append: nil))

        var movie: Movie?
        tmdb.getMovieDetails(for: allQuietMovieId, appending: nil) { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsMovieDetailsWithImages() {
        var movie: Movie?
        tmdb.getMovieDetails(for: allQuietMovieId, appending: [.images(languages: ["en"])]) { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())

    }

    func testReturnsMovieDetailsWithAllExtraDetails() {
        var movie: Movie?
        tmdb.getMovieDetails(for: allQuietMovieId, appending: [.images(languages: nil), .reviews(language: nil), .videos(language: nil)]) { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())

    }


    func testReturnsAlternativeTitlesForMovie() {
        stubHelper.stubWithLocalFile(Movies.alternativeTitles(movieId: allQuietMovieId))

        var alternatives: AlternativeTitlesResponse?
        tmdb.getAlternativeMovieTitles(movieId: allQuietMovieId) { result in
            alternatives = result.value
        }
        expect(alternatives).toEventuallyNot(beNil())
    }

    func testReturnsChanges() {
        stubHelper.stubWithLocalFile(Movies.changes(movieId: allQuietMovieId))

        var changes: ChangesResponse?
        tmdb.getMovieChanges(movieId: allQuietMovieId) { result in
            changes = result.value
        }
        expect(changes).toEventuallyNot(beNil())
    }

    func testReturnsCredits() {
        stubHelper.stubWithLocalFile(Movies.credits(movieId: blackPantherMovieId))

        var credits: CreditsResponse?
        tmdb.getMovieCredits(movieId: blackPantherMovieId) { result in
            credits = result.value
        }
        expect(credits).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() {
        stubHelper.stubWithLocalFile(Movies.externalIds(movieId: blackPantherMovieId))

        var ids: ExternalIds?
        tmdb.getExternalIds(movieId: blackPantherMovieId) { result in
            ids = result.value
        }
        expect(ids).toEventuallyNot(beNil())
    }

    func testReturnsMovieImages() {
        stubHelper.stubWithLocalFile(Movies.images(movieId: blackPantherMovieId))

        var images: ImagesResponse?
        tmdb.getMovieImages(movieId: blackPantherMovieId) { result in
            images = result.value
        }
        expect(images).toEventuallyNot(beNil())
    }

    func testReturnsKeywords() {
        stubHelper.stubWithLocalFile(Movies.keywords(movieId: blackPantherMovieId))

        var words: KeywordsResponse?
        tmdb.getMovieKeywords(movieId: blackPantherMovieId) { result in
            words = result.value
        }
        expect(words).toEventuallyNot(beNil())
    }

    func testReturnsReleaseDates() {
        stubHelper.stubWithLocalFile(Movies.releaseDates(movieId: blackPantherMovieId))

        var dates: ReleaseDatesResponse?
        tmdb.getMovieReleaseDates(movieId: blackPantherMovieId) { result in
            dates = result.value
        }
        expect(dates).toEventuallyNot(beNil())
    }

    func testReturnsVideos() {
        stubHelper.stubWithLocalFile(Movies.videos(movieId: blackPantherMovieId))

        var videos: VideosResponse?
        tmdb.getMovieVideos(movieId: blackPantherMovieId) { result in
            videos = result.value
        }
        expect(videos).toEventuallyNot(beNil())
    }

    func testReturnsTranslations() {
        stubHelper.stubWithLocalFile(Movies.translations(movieId: blackPantherMovieId))

        var translations: TranslationsResponse?
        tmdb.getMovieTranslations(movieId: blackPantherMovieId) { result in
            translations = result.value
        }
        expect(translations).toEventuallyNot(beNil())
    }

    func testReturnsRecommendations() {
        stubHelper.stubWithLocalFile(Movies.recommendations(movieId: blackPantherMovieId, pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.getMovieRecommendations(movieId: blackPantherMovieId, pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsSimilarMovies() {
        stubHelper.stubWithLocalFile(Movies.similarMovies(movieId: blackPantherMovieId, pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.getSimilarMovies(for: blackPantherMovieId, pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsReviews() {
        stubHelper.stubWithLocalFile(Movies.reviews(movieId: blackPantherMovieId, pageNumber: 1))

        var reviews: ReviewsResponse?
        tmdb.getReviews(for: blackPantherMovieId, pageNumber: 1) { result in
            reviews = result.value
        }
        expect(reviews).toEventuallyNot(beNil())
    }

    func testReturnsLists() {
        stubHelper.stubWithLocalFile(Movies.lists(movieId: blackPantherMovieId, pageNumber: 1))

        var lists: ListsResponse?
        tmdb.getLists(for: blackPantherMovieId, pageNumber: 1) { result in
            lists = result.value
        }
        expect(lists).toEventuallyNot(beNil())
    }

    func testReturnsNowPlayingMovies() {
        stubHelper.stubWithLocalFile(Movies.nowPlaying(pageNumber: 1))

        var nowPlaying: NowPlayingMoviesResponse?
        tmdb.getNowPlayingMovies(pageNumber: 1) { result in
            nowPlaying = result.value
        }
        expect(nowPlaying).toEventuallyNot(beNil())
    }

    func testReturnsLatestMovie() {
        stubHelper.stubWithLocalFile(Movies.latest)

        var movie: Movie?
        tmdb.getLatestMovie { result in
            movie = result.value
        }
        expect(movie).toEventuallyNot(beNil())
    }

    func testReturnsPopularMovies() {
        stubHelper.stubWithLocalFile(Movies.popular(pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.getPopularMovies(pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsTopRatedMovies() {
        stubHelper.stubWithLocalFile(Movies.topRated(pageNumber: 1))

        var movies: PopularMoviesResponse?
        tmdb.getTopRatedMovies(pageNumber: 1) { result in
            movies = result.value
        }
        expect(movies).toEventuallyNot(beNil())
    }

    func testReturnsUpcomingMovies() {
        stubHelper.stubWithLocalFile(Movies.upcoming(pageNumber: 1))

        var nowPlaying: NowPlayingMoviesResponse?
        tmdb.getUpcomingMovies(pageNumber: 1) { result in
            nowPlaying = result.value
        }
        expect(nowPlaying).toEventuallyNot(beNil())

    }

}
