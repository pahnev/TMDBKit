//
//  TVEndpointTests.swift
//  TMDBKitTests
//
//  Created by Kirill Pahnev on 01/12/2019.
//

import Nimble
import XCTest
@testable import TMDBKit

class TVEndpointTests: TMDBTestCase {
    private let gameOfThrones = 1399

    func testReturnsDetails() {
        stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, append: nil))

        var result: TVDetails?
        tmdb.tv.details(for: gameOfThrones, appending: nil) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsDetailsWithAppendedData() {
        stubHelper.stubWithLocalFile(TV.details(tvId: gameOfThrones, append: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)]))

        var result: TVDetails?
        tmdb.tv.details(for: gameOfThrones, appending: [.reviews(language: nil), .videos(language: nil), .images(languages: nil)]) { res in
            result = res.value
        }
        expect(result?.reviews).toEventuallyNot(beNil())
        expect(result?.videos).toEventuallyNot(beNil())
        expect(result?.images).toEventuallyNot(beNil())
    }

    func testDetailsURL() {
        let withoutAppending = TV.details(tvId: 1, append: nil)
        XCTAssertEqual(withoutAppending.url.absoluteString, "https://api.themoviedb.org/3/tv/1")

        let appendingReviews = TV.details(tvId: 1, append: [.reviews(language: nil)])
        XCTAssertEqual(appendingReviews.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=reviews")

        let appendingVideos = TV.details(tvId: 1, append: [.videos(language: nil)])
        XCTAssertEqual(appendingVideos.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=videos")

        let appendingImages = TV.details(tvId: 1, append: [.images(languages: nil)])
        XCTAssertEqual(appendingImages.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=images")

        let appendingEverything = TV.details(tvId: 1, append: [
            .reviews(language: "en"),
            .images(languages: ["en", "es"]),
            .videos(language: "en")
        ])
        XCTAssertEqual(appendingEverything.url.absoluteString, "https://api.themoviedb.org/3/tv/1?append_to_response=reviews,images,videos&language=en&include_image_language=en,es&language=en")
    }

    func testReturnsAlternativeTitles() {
        stubHelper.stubWithLocalFile(TV.alternativeTitles(tvId: gameOfThrones))

        var result: AlternativeTvTitlesResponse?
        tmdb.tv.alternativeTitles(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsChanges() {
        stubHelper.stubWithLocalFile(TV.changes(tvId: gameOfThrones))

        var result: TVChangesResponse?
        tmdb.tv.changes(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsContentRatings() {
        stubHelper.stubWithLocalFile(TV.contentRatings(tvId: gameOfThrones))

        var result: ContentRatingsResponse?
        tmdb.tv.contentRatings(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsCredits() {
        stubHelper.stubWithLocalFile(TV.credits(tvId: gameOfThrones))

        var result: TVCreditsResponse?
        tmdb.tv.credits(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsEpisodeGroups() {
        stubHelper.stubWithLocalFile(TV.episodeGroups(tvId: 30983))

        var result: EpisodeGroupsResponse?
        tmdb.tv.episodeGroups(for: 30983) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsExternalIds() {
        stubHelper.stubWithLocalFile(TV.externalIds(tvId: gameOfThrones))

        var result: ExternalIds?
        tmdb.tv.externalIds(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsImages() {
        stubHelper.stubWithLocalFile(TV.images(tvId: gameOfThrones))

        var result: ImagesResponse?
        tmdb.tv.images(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsKeywords() {
        stubHelper.stubWithLocalFile(TV.keywords(tvId: gameOfThrones))

        var result: TVKeywordsResponse?
        tmdb.tv.keywords(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsRecommendations() {
        stubHelper.stubWithLocalFile(TV.recommendations(tvId: gameOfThrones, pageNumber: 1))

        var result: RecommendationsResponse?
        tmdb.tv.recommendations(for: gameOfThrones, pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsReviews() {
        stubHelper.stubWithLocalFile(TV.reviews(tvId: gameOfThrones, pageNumber: 1))

        var result: ReviewsResponse?
        tmdb.tv.reviews(for: gameOfThrones, pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsScreenedTheatrically() {
        stubHelper.stubWithLocalFile(TV.screenedTheatrically(tvId: gameOfThrones))

        var result: ScreenedTheatricallyResponse?
        tmdb.tv.screenedTheatrically(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsSimilarShows() {
        stubHelper.stubWithLocalFile(TV.similarShows(tvId: gameOfThrones, pageNumber: 1))

        var result: SimilarShowsResponse?
        tmdb.tv.similarShows(for: gameOfThrones, pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsTranslations() {
        stubHelper.stubWithLocalFile(TV.translations(tvId: gameOfThrones))

        var result: TranslationsResponse?
        tmdb.tv.translations(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsVideos() {
        stubHelper.stubWithLocalFile(TV.videos(tvId: gameOfThrones))

        var result: VideosResponse?
        tmdb.tv.videos(for: gameOfThrones) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsLatestShows() {
        stubHelper.stubWithLocalFile(TV.latest)

        var result: TVDetails?
        tmdb.tv.latest { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsAiringToday() {
        stubHelper.stubWithLocalFile(TV.airingToday(pageNumber: 1))

        var result: SimilarShowsResponse?
        tmdb.tv.airingToday(pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsOnAirShows() {
        stubHelper.stubWithLocalFile(TV.onTheAir(pageNumber: 1))

        var result: SimilarShowsResponse?
        tmdb.tv.onTheAir(pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsPopular() {
        stubHelper.stubWithLocalFile(TV.popular(pageNumber: 1))

        var result: SimilarShowsResponse?
        tmdb.tv.popular(pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsTopRated() {
        stubHelper.stubWithLocalFile(TV.topRated(pageNumber: 1))

        var result: SimilarShowsResponse?
        tmdb.tv.topRated(pageNumber: 1) { res in
            result = res.value
        }
        expect(result).toEventuallyNot(beNil())
    }
}
