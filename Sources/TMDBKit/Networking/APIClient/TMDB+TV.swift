//
//  TMDB+TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

public struct TVEndpoints {
    let tmdb: TMDB

    public func details(for tvId: Int, appending details: [DetailsAppendable]?, completion: @escaping TMDBResult<TVDetails>) {
        tmdb.fetchObject(ofType: TVDetails.self, endpoint: TV.details(tvId: tvId, append: details), completion: completion)
    }

    public func accountStates(for tvId: Int) {
        // TODO:
    }

    public func alternativeTitles(for tvId: Int, completion: @escaping TMDBResult<AlternativeTvTitlesResponse>) {
        tmdb.fetchObject(ofType: AlternativeTvTitlesResponse.self, endpoint: TV.alternativeTitles(tvId: tvId), completion: completion)
    }

    public func changes(for tvId: Int, completion: @escaping TMDBResult<TVChangesResponse>) {
        tmdb.fetchObject(ofType: TVChangesResponse.self, endpoint: TV.changes(tvId: tvId), completion: completion)
    }

    public func contentRatings(for tvId: Int, completion: @escaping TMDBResult<ContentRatingsResponse>) {
        tmdb.fetchObject(ofType: ContentRatingsResponse.self, endpoint: TV.contentRatings(tvId: tvId), completion: completion)
    }

    /// Get the cast and crew for a tv show.
    public func credits(for tvId: Int, completion: @escaping TMDBResult<TVCreditsResponse>) {
        tmdb.fetchObject(ofType: TVCreditsResponse.self, endpoint: TV.credits(tvId: tvId), completion: completion)
    }

    public func episodeGroups(for tvId: Int, completion: @escaping TMDBResult<EpisodeGroupsResponse>) {
        tmdb.fetchObject(ofType: EpisodeGroupsResponse.self, endpoint: TV.episodeGroups(tvId: tvId), completion: completion)
    }

    public func externalIds(for tvId: Int, completion: @escaping TMDBResult<ExternalIds>) {
        tmdb.fetchObject(ofType: ExternalIds.self, endpoint: TV.externalIds(tvId: tvId), completion: completion)
    }

    /// Get the images that belong to a movie.
    /// Querying images with a `language` parameter will filter the results. If you want to include a fallback language (especially useful for backdrops) you can use the `include_image_language` parameter. This should be a comma separated value like so: `include_image_language=en,null`.
    public func images(for tvId: Int, completion: @escaping TMDBResult<ImagesResponse>) {
        tmdb.fetchObject(ofType: ImagesResponse.self, endpoint: TV.images(tvId: tvId), completion: completion)
    }

    /// Get the keywords that have been added to a movie
    public func keywords(for tvId: Int, completion: @escaping TMDBResult<TVKeywordsResponse>) {
        tmdb.fetchObject(ofType: TVKeywordsResponse.self, endpoint: TV.keywords(tvId: tvId), completion: completion)
    }

    public func recommendations(for tvId: Int, pageNumber: PageNumber, completion: @escaping TMDBResult<RecommendationsResponse>) {
        tmdb.fetchObject(ofType: RecommendationsResponse.self,
                         endpoint: TV.recommendations(tvId: tvId, pageNumber: pageNumber),
                         completion: completion)
    }

    /// Get the user reviews for a movie.
    public func reviews(for tvId: Int, pageNumber: PageNumber, completion: @escaping TMDBResult<ReviewsResponse>) {
        tmdb.fetchObject(ofType: ReviewsResponse.self, endpoint: TV.reviews(tvId: tvId, pageNumber: pageNumber), completion: completion)
    }

    public func screenedTheatrically(for tvId: Int, completion: @escaping TMDBResult<ScreenedTheatricallyResponse>) {
        tmdb.fetchObject(ofType: ScreenedTheatricallyResponse.self, endpoint: TV.screenedTheatrically(tvId: tvId), completion: completion)
    }

    public func similarShows(for tvId: Int, pageNumber: PageNumber, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: TV.similarShows(tvId: tvId, pageNumber: pageNumber), completion: completion)
    }

    public func translations(for tvId: Int, completion: @escaping TMDBResult<TranslationsResponse>) {
        tmdb.fetchObject(ofType: TranslationsResponse.self, endpoint: TV.translations(tvId: tvId), completion: completion)
    }

    public func videos(for tvId: Int, completion: @escaping TMDBResult<VideosResponse>) {
        tmdb.fetchObject(ofType: VideosResponse.self, endpoint: TV.videos(tvId: tvId), completion: completion)
    }

    public func latest(completion: @escaping TMDBResult<TVDetails>) {
        tmdb.fetchObject(ofType: TVDetails.self, endpoint: TV.latest, completion: completion)
    }

    public func airingToday(pageNumber: PageNumber, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: TV.airingToday(pageNumber: pageNumber), completion: completion)
    }

    public func onTheAir(pageNumber: PageNumber, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: TV.onTheAir(pageNumber: pageNumber), completion: completion)
    }

    public func popular(pageNumber: PageNumber, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: TV.popular(pageNumber: pageNumber), completion: completion)
    }

    public func topRated(pageNumber: PageNumber, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self, endpoint: TV.topRated(pageNumber: pageNumber), completion: completion)
    }

    // MARK: - Post

    public func rateShow(_ tvId: Int, rating: Double, completion: @escaping TMDBResult<StatusResponse>) {
        tmdb.authenticatedRequestAndParse(TV.rateShow(tvId: tvId, rating: rating), completion: completion)
    }

    // MARK: - Delete

    public func deleteRating(of tvId: Int, completion: @escaping TMDBResult<StatusResponse>) {
        tmdb.authenticatedRequestAndParse(TV.deleteRating(tvId: tvId), completion: completion)
    }
}
