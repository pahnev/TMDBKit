//
//  TMDB+TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

public struct TVEndpoints {
    let tmdb: TMDB

    /// Get the primary TV show details by id.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - details: Object query to include other details in the response. Read more about this here https://developers.themoviedb.org/3/getting-started/append-to-response.
    ///   - completion: Result of a `TVDetails` or `TMDBError`.
    public func details(for tvId: Int, language: String? = nil, appending details: [DetailsAppendable]?, completion: @escaping TMDBResult<TVDetails>) {
        tmdb.fetchObject(ofType: TVDetails.self,
                         endpoint: TV.details(tvId: tvId, language: language, append: details),
                         completion: completion)
    }

    /// Grab the following account states for a session:
    /// TV show rating
    /// If it belongs to your watchlist
    /// If it belongs to your favourite list
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `AccountState` or `TMDBError`.
    public func accountStates(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AccountState>) {
        tmdb.fetchObject(ofType: AccountState.self,
                         endpoint: TV.accountStates(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Get the aggregate credits (cast and crew) that have been added to a TV show.
    /// This call differs from the main `credits` call in that it does not return the newest season but rather, is a view of all the entire cast & crew for all episodes belonging to a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `AggregateCredits` or `TMDBError`.
    public func aggregateCredits(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AggregateCredits>) {
        tmdb.fetchObject(ofType: AggregateCredits.self,
                         endpoint: TV.aggregateCredits(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Returns all of the alternative titles for a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `AlternativeTvTitlesResponse` or `TMDBError`.
    public func alternativeTitles(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AlternativeTvTitlesResponse>) {
        tmdb.fetchObject(ofType: AlternativeTvTitlesResponse.self,
                         endpoint: TV.alternativeTitles(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Get the changes for a TV show. By default only the last 24 hours are returned.
    /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
    ///
    /// TV show changes are different than `Movie` changes in that there are some edits on seasons and episodes that will create a change entry at the show level. These can be found under the season and episode keys. These keys will contain a `seriesId` and `episodeId`. You can use the `seasonChanges` and `episodeChanges` methods to look these up individually.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - pageNumber: The page number to fetch.
    ///   - completion: Result of a `TVChangesResponse` or `TMDBError`.
    public func changes(for tvId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<TVChangesResponse>) {
        // TODO: start_date and end_date query
        tmdb.fetchObject(ofType: TVChangesResponse.self,
                         endpoint: TV.changes(tvId: tvId, pageNumber: pageNumber),
                         completion: completion)
    }

    /// Get the list of content ratings (certifications) that have been added to a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `ContentRatingsResponse` or `TMDBError`.
    public func contentRatings(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ContentRatingsResponse>) {
        tmdb.fetchObject(ofType: ContentRatingsResponse.self,
                         endpoint: TV.contentRatings(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Get the cast and crew for a tv show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `TVCreditsResponse` or `TMDBError`.
    public func credits(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<TVCreditsResponse>) {
        tmdb.fetchObject(ofType: TVCreditsResponse.self,
                         endpoint: TV.credits(tvId: tvId, language: language),
                         completion: completion)
    }


    /// Get all of the episode groups that have been created for a TV show. With a group ID you can call the get TV episode group details method.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `EpisodeGroupsResponse` or `TMDBError`.
    public func episodeGroups(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<EpisodeGroupsResponse>) {
        tmdb.fetchObject(ofType: EpisodeGroupsResponse.self,
                         endpoint: TV.episodeGroups(tvId: tvId, language: language),
                         completion: completion)
    }


    /// Get the external ids for a TV show. We currently support the following external sources.
    ///
    /// | **Media Databases** | **Social IDs** |
    /// | :-----------------: | :------------: |
    /// |       IMDb ID       |    Facebook    |
    /// |       TVDB ID       |   Instagram    |
    /// |                     |    Twitter     |
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `ExternalIds` or `TMDBError`.
    public func externalIds(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ExternalIds>) {
        tmdb.fetchObject(ofType: ExternalIds.self,
                         endpoint: TV.externalIds(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Get the images that belong to a TV show.
    /// Querying images with a `language` parameter will filter the results. If you want to include a fallback language (especially useful for backdrops) you can use the `include_image_language` parameter. This should be a comma separated value like so: `include_image_language=en,null`.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `ImagesResponse` or `TMDBError`.
    public func images(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>) {
        tmdb.fetchObject(ofType: ImagesResponse.self,
                         endpoint: TV.images(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Get the keywords that have been added to a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of a `TVKeywordsResponse` or `TMDBError`.
    public func keywords(for tvId: Int, completion: @escaping TMDBResult<TVKeywordsResponse>) {
        tmdb.fetchObject(ofType: TVKeywordsResponse.self,
                         endpoint: TV.keywords(tvId: tvId),
                         completion: completion)
    }

    /// Get the list of TV show recommendations for this item.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of a `ImagesResponse` or `TMDBError`.
    public func recommendations(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<RecommendationsResponse>) {
        tmdb.fetchObject(ofType: RecommendationsResponse.self,
                         endpoint: TV.recommendations(tvId: tvId, pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get the user reviews for a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `ReviewsResponse` or `TMDBError`.
    public func reviews(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ReviewsResponse>) {
        tmdb.fetchObject(ofType: ReviewsResponse.self,
                         endpoint: TV.reviews(tvId: tvId, pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get a list of seasons or episodes that have been screened in a film festival or theatre.
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of a `ScreenedTheatricallyResponse` or `TMDBError`.
    public func screenedTheatrically(for tvId: Int, completion: @escaping TMDBResult<ScreenedTheatricallyResponse>) {
        tmdb.fetchObject(ofType: ScreenedTheatricallyResponse.self, endpoint: TV.screenedTheatrically(tvId: tvId), completion: completion)
    }

    /// Get a list of similar TV shows. These items are assembled by looking at keywords and genres.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `SimilarShowsResponse` or `TMDBError`.
    public func similarShows(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self,
                         endpoint: TV.similarShows(tvId: tvId, pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get a list of the translations that exist for a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of a `TranslationsResponse` or `TMDBError`.
    public func translations(for tvId: Int, completion: @escaping TMDBResult<TranslationsResponse>) {
        tmdb.fetchObject(ofType: TranslationsResponse.self,
                         endpoint: TV.translations(tvId: tvId),
                         completion: completion)
    }

    /// Get the videos that have been added to a TV show.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `VideosResponse` or `TMDBError`.
    public func videos(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<VideosResponse>) {
        tmdb.fetchObject(ofType: VideosResponse.self,
                         endpoint: TV.videos(tvId: tvId, language: language),
                         completion: completion)
    }

    /// Powered by our partnership with JustWatch, you can query this method to get a list of the availabilities per country by provider.
    ///
    /// This is not going to return full deep links, but rather, it's just enough information to display what's available where.
    ///
    /// You can link to the provided TMDB URL to help support TMDB and provide the actual deep links to the content.
    ///
    /// - NOTE: In order to use this data you must attribute the source of the data as JustWatch.
    /// If TMDB finds any usage not complying with these terms we will revoke access to the API.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of a `WatchProviderResponse` or `TMDBError`.
    public func watchProviders(for tvId: Int, completion: @escaping TMDBResult<WatchProviderResponse>) {
        tmdb.fetchObject(ofType: WatchProviderResponse.self,
                         endpoint: TV.watchProviders(tvId: tvId),
                         completion: completion)
    }

    /// Get the most newly created TV show. This is a live response and will continuously change.
    ///
    /// - Parameters:
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `TVDetails` or `TMDBError`.
    public func latest(in language: String? = nil, completion: @escaping TMDBResult<TVDetails>) {
        tmdb.fetchObject(ofType: TVDetails.self,
                         endpoint: TV.latest(language: language),
                         completion: completion)
    }

    /// Get a list of TV shows that are airing today. This query is purely day based as we do not currently support airing times.
    ///
    /// You can specify a timezone to offset the day calculation. Without a specified timezone, this query defaults to EST (Eastern Time UTC-05:00).
    ///
    /// - Parameters:
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `SimilarShowsResponse` or `TMDBError`.
    public func airingToday(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self,
                         endpoint: TV.airingToday(pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get a list of shows that are currently on the air.
    /// This query looks for any TV show that has an episode with an air date in the next 7 days.
    ///
    /// - Parameters:
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `SimilarShowsResponse` or `TMDBError`.
    public func onTheAir(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self,
                         endpoint: TV.onTheAir(pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get a list of the current popular TV shows on TMDB. This list updates daily.
    ///
    /// - Parameters:
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `SimilarShowsResponse` or `TMDBError`.
    public func popular(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self,
                         endpoint: TV.popular(pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    /// Get a list of the top rated TV shows on TMDB.
    ///
    /// - Parameters:
    ///   - pageNumber: The page number to fetch.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `SimilarShowsResponse` or `TMDBError`.
    public func topRated(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        tmdb.fetchObject(ofType: SimilarShowsResponse.self,
                         endpoint: TV.topRated(pageNumber: pageNumber, language: language),
                         completion: completion)
    }

    // MARK: - Post

    /// Rate a TV show.
    /// A valid session or guest session ID is required.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - rating: The rating. The value is expected to be between 0.5 and 10.0.
    ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
    ///   - completion: Result of a `StatusResponse` or `TMDBError`.
    public func rateShow(_ tvId: Int, rating: Double, completion: @escaping TMDBResult<StatusResponse>) {
        tmdb.authenticatedRequestAndParse(TV.rateShow(tvId: tvId, rating: rating), completion: completion)
    }

    // MARK: - Delete

    /// Remove your rating for a TV show.
    /// A valid session or guest session ID is required.
    ///
    /// - Parameters:
    ///   - tvId: The id of the TV show.
    ///   - completion: Result of the action, either `StatusResponse` or `TMDBError`.
    public func deleteRating(of tvId: Int, completion: @escaping TMDBResult<StatusResponse>) {
        tmdb.authenticatedRequestAndParse(TV.deleteRating(tvId: tvId), completion: completion)
    }
}
