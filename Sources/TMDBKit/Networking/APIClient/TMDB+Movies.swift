//
//  TMDB+Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

public extension TMDB {
    struct MovieEndpoints {
        let tmdb: TMDB

        /// Get the primary information about a movie
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - details: Object query to include other details in the response. Read more about this here https://developers.themoviedb.org/3/getting-started/append-to-response.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `Movie` or `TMDBError`.
        public func details(for movieId: Int, appending details: [DetailsAppendable]?, language: String? = nil, completion: @escaping TMDBResult<Movie>) {
            tmdb.fetchObject(ofType: Movie.self, endpoint: Movies.details(movieId: movieId, append: details, language: language), completion: completion)
        }

        public func accountStates(for movieId: Int) {
            // TODO:
        }

        /// Get all of the alternative titles for a movie. By default returns all title for all countries.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - country: A country code in ISO 3166-1 format, to filter the results for that country.
        ///   - completion: Result of a `AlternativeTitlesResponse` or `TMDBError`.
        public func alternativeTitles(for movieId: Int, country: String? = nil, completion: @escaping TMDBResult<AlternativeTitlesResponse>) {
            tmdb.fetchObject(ofType: AlternativeTitlesResponse.self, endpoint: Movies.alternativeTitles(movieId: movieId, country: country), completion: completion)
        }

        /// Get the changes for a movie. By default only the last 24 hours are returned.
        /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - completion: Result of a `ChangesResponse` or `TMDBError`.
        public func changes(for movieId: Int, completion: @escaping TMDBResult<ChangesResponse>) {
            // TODO: Pagination and date query
            tmdb.fetchObject(ofType: ChangesResponse.self, endpoint: Movies.changes(movieId: movieId), completion: completion)
        }

        /// Get the cast and crew for a movie.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `CreditsResponse` or `TMDBError`.
        public func credits(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<CreditsResponse>) {
            tmdb.fetchObject(ofType: CreditsResponse.self, endpoint: Movies.credits(movieId: movieId, language: language), completion: completion)
        }

        /// Get the external ids for a movie. We currently support the following external sources.
        ///
        /// | **Media Databases** | **Social IDs** |
        /// | :-----------------: | :------------: |
        /// |       IMDb ID       |    Facebook    |
        /// |                     |   Instagram    |
        /// |                     |    Twitter     |
        ///
        public func externalIds(for movieId: Int, completion: @escaping TMDBResult<ExternalIds>) {
            tmdb.fetchObject(ofType: ExternalIds.self, endpoint: Movies.externalIds(movieId: movieId), completion: completion)
        }

        /// Get the images that belong to a movie.
        /// Querying images with a `language` parameter will filter the results for that language.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - language: A language string in ISO 639-1 format, to get images for specific language.
        ///   Can include multiple languages, as long as the languages are comma separated like so: `en,es`.
        ///   If you want to include a fallback language (especially useful for backdrops) you can use add `null` at the end.
        ///   Defaults to `en-US`.
        ///
        ///   - completion: Result of a `ImagesResponse` or `TMDBError`.
        public func images(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>) {
            tmdb.fetchObject(ofType: ImagesResponse.self, endpoint: Movies.images(movieId: movieId, language: language), completion: completion)
        }

        /// Get the keywords that have been added to a movie.
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - completion: Result of a `KeywordsResponse` or `TMDBError`.
        public func keywords(for movieId: Int, completion: @escaping TMDBResult<KeywordsResponse>) {
            tmdb.fetchObject(ofType: KeywordsResponse.self, endpoint: Movies.keywords(movieId: movieId), completion: completion)
        }

        /// Get the release date along with the certification for a movie.
        /// Release dates support different types:
        /// 1. Premiere
        /// 2. Theatrical (limited)
        /// 3. Theatrical
        /// 4. Digital
        /// 5. Physical
        /// 6. TV
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - completion: Result of a `ReleaseDatesResponse` or `TMDBError`.
        public func releaseDates(for movieId: Int, completion: @escaping TMDBResult<ReleaseDatesResponse>) {
            tmdb.fetchObject(ofType: ReleaseDatesResponse.self, endpoint: Movies.releaseDates(movieId: movieId), completion: completion)
        }

        /// Get the videos that have been added to a movie.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - language: A language string in ISO 639-1 format, to get videos for specific language.
        ///   Can include multiple languages, as long as the languages are comma separated like so: `en,es`.
        ///   Defaults to `en-US`.
        ///   - completion: Result of a `VideosResponse` or `TMDBError`.
        public func videos(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<VideosResponse>) {
            tmdb.fetchObject(ofType: VideosResponse.self, endpoint: Movies.videos(movieId: movieId, language: language), completion: completion)
        }

        public func watchProviders() {
            // TODO: Implement
            fatalError("TODO")
        }

        /// Get a list of translations that have been created for a movie.
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - completion: Result of a `TranslationsResponse` or `TMDBError`.
        public func translations(for movieId: Int, completion: @escaping TMDBResult<TranslationsResponse>) {
            tmdb.fetchObject(ofType: TranslationsResponse.self, endpoint: Movies.translations(movieId: movieId), completion: completion)
        }

        /// Get a list of recommended movies for a movie.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PopularMoviesResponse` or `TMDBError`.
        public func recommendations(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self,
                             endpoint: Movies.recommendations(movieId: movieId, pageNumber: pageNumber, language: language),
                             completion: completion)
        }

        /// Get a list of similar movies. This is not the same as the "Recommendation" system you see on the website.
        /// These items are assembled by looking at keywords and genres.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PopularMoviesResponse` or `TMDBError`.
        public func similarMovies(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self,
                             endpoint: Movies.similarMovies(movieId: movieId, pageNumber: pageNumber, language: language),
                             completion: completion)
        }

        /// Get the user reviews for a movie.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `ReviewsResponse` or `TMDBError`.
        public func reviews(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ReviewsResponse>) {
            tmdb.fetchObject(ofType: ReviewsResponse.self,
                             endpoint: Movies.reviews(movieId: movieId, pageNumber: pageNumber, language: language),
                             completion: completion)
        }

        /// Get a list of lists that this movie belongs to.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `ListsResponse` or `TMDBError`.
        public func lists(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ListsResponse>) {
            tmdb.fetchObject(ofType: ListsResponse.self,
                             endpoint: Movies.lists(movieId: movieId, pageNumber: pageNumber, language: language),
                             completion: completion)
        }

        /// Get the most newly created movie. This is a live response and will continuously change
        /// - Parameters:
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `Movie` or `TMDBError`.
        public func latest(language: String? = nil, completion: @escaping TMDBResult<Movie>) {
            tmdb.fetchObject(ofType: Movie.self, endpoint: Movies.latest(language: language), completion: completion)
        }

        /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
        /// You can optionally specify a `region` parameter which will narrow the search to only look for theatrical release dates within the specified country.
        ///
        /// - Parameters:
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - region: A country code in ISO 3166-1 format, to filter the results for that country.
        ///   - completion: Result of a `NowPlayingMoviesResponse` or `TMDBError`.
        public func nowPlaying(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<NowPlayingMoviesResponse>) {
            tmdb.fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.nowPlaying(pageNumber: pageNumber, language: language, region: region), completion: completion)
        }

        /// Get the top rated movies on TMDb.
        ///
        /// - Parameters:
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - region: A country code in ISO 3166-1 format, to filter the results for that country.
        ///   - completion: Result of a `PopularMoviesResponse` or `TMDBError`.
        public func topRated(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.topRated(pageNumber: pageNumber, language: language, region: region), completion: completion)
        }

        /// Get a list of the current popular movies on TMDb. This list updates daily.
        ///
        /// - Parameters:
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - region: A country code in ISO 3166-1 format, to filter the results for that country.
        ///   - completion: Result of a `PopularMoviesResponse` or `TMDBError`.
        public func popular(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.popular(pageNumber: pageNumber, language: language, region: region), completion: completion)
        }

        /// Rate a movie.
        /// A valid session or guest session ID is required.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie` to rate.
        ///   - rating: The rating. The value is expected to be between 0.5 and 10.0.
        ///   - completion: Result of the action, either `StatusResponse` or `TMDBError`.
        public func rateMovie(_ movieId: Int, rating: Double, completion: @escaping TMDBResult<StatusResponse>) {
            tmdb.authenticatedRequestAndParse(Movies.rateMovie(rating: rating, movieId: movieId), completion: completion)
        }


        /// Remove your rating for a movie.
        /// A valid session or guest session ID is required.
        ///
        /// - Parameters:
        ///   - movieId: The id of the `Movie`.
        ///   - completion: Result of the action, either `StatusResponse` or `TMDBError`.
        public func deleteRating(of movieId: Int, completion: @escaping TMDBResult<StatusResponse>) {
            tmdb.authenticatedRequestAndParse(Movies.deleteRating(movieId: movieId), completion: completion)
        }

        /// Get a list of upcoming movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
        /// You can optionally specify a `region` parameter which will narrow the search to only look for theatrical release dates within the specified country.
        ///
        /// - Parameters:
        ///   - pageNumber: The page number to fetch.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - region: A country code in ISO 3166-1 format, to filter the results for that country.
        ///   - completion: Result of a `NowPlayingMoviesResponse` or `TMDBError`.
        public func upcoming(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<NowPlayingMoviesResponse>) {
            tmdb.fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.upcoming(pageNumber: pageNumber, language: language, region: region), completion: completion)
        }
    }
}
