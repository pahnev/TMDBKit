//
//  TMDB+Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

extension TMDB {
    public struct MovieEndpoints {
        let tmdb: TMDB
        let sessionProvider: SessionProvider?

        /// Get the primary information about a movie
        /// Supports append_to_response. Read more about this here https://developers.themoviedb.org/3/getting-started/append-to-response.
        ///
        /// - Parameters:
        ///   - movieId: Movie
        ///   - completion: Result of `Movie` or `TMDBError`
        public func details(for movieId: Int, appending details: [DetailsAppendable]?, completion: @escaping TMBDResult<Movie>) {
            tmdb.fetchObject(ofType: Movie.self, endpoint: Movies.details(movieId: movieId, append: details), completion: completion)
        }

        public func accountStates(for movieId: Int) {
            // TODO
        }

        /// Get all of the alternative titles for a movie
        public func alternativeTitles(for movieId: Int, completion: @escaping TMBDResult<AlternativeTitlesResponse>) {
            tmdb.fetchObject(ofType: AlternativeTitlesResponse.self, endpoint: Movies.alternativeTitles(movieId: movieId), completion: completion)
        }

        /// Get the changes for a movie. By default only the last 24 hours are returned.
        /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
        ///
        /// - Parameters:
        ///   - movieId: Movie
        ///   - completion: Closure
        public func changes(for movieId: Int, completion: @escaping TMBDResult<ChangesResponse>) {
            tmdb.fetchObject(ofType: ChangesResponse.self, endpoint: Movies.changes(movieId: movieId), completion: completion)
        }

        /// Get the cast and crew for a movie.
        public func credits(for movieId: Int, completion: @escaping TMBDResult<CreditsResponse>) {
            tmdb.fetchObject(ofType: CreditsResponse.self, endpoint: Movies.credits(movieId: movieId), completion: completion)
        }

        /// Get the external ids for a movie. We currently support the following external sources.
        ///
        /// | **Media Databases** | **Social IDs** |
        /// | :-----------------: | :------------: |
        /// |       IMDb ID       |    Facebook    |
        /// |                     |   Instagram    |
        /// |                     |    Twitter     |
        ///
        public func externalIds(for movieId: Int, completion: @escaping TMBDResult<ExternalIds>) {
            tmdb.fetchObject(ofType: ExternalIds.self, endpoint: Movies.externalIds(movieId: movieId), completion: completion)
        }

        /// Get the images that belong to a movie.
        /// Querying images with a `language` parameter will filter the results. If you want to include a fallback language (especially useful for backdrops) you can use the `include_image_language` parameter. This should be a comma seperated value like so: `include_image_language=en,null`.
        public func images(for movieId: Int, completion: @escaping TMBDResult<ImagesResponse>) {
            tmdb.fetchObject(ofType: ImagesResponse.self, endpoint: Movies.images(movieId: movieId), completion: completion)
        }

        /// Get the keywords that have been added to a movie
        public func keywords(for movieId: Int, completion: @escaping TMBDResult<KeywordsResponse>) {
            tmdb.fetchObject(ofType: KeywordsResponse.self, endpoint: Movies.keywords(movieId: movieId), completion: completion)
        }

        /// Get the release date along with the certification for a movie.
        /// 1. Release dates support different types:
        /// 2. Premiere
        /// 3. Theatrical (limited)
        /// 4. Theatrical
        /// 5. Digital
        /// 6. Physical
        /// 7. TV
        public func releaseDates(for movieId: Int, completion: @escaping TMBDResult<ReleaseDatesResponse>) {
            tmdb.fetchObject(ofType: ReleaseDatesResponse.self, endpoint: Movies.releaseDates(movieId: movieId), completion: completion)
        }

        /// Get the videos that have been added to a movie.
        public func videos(for movieId: Int, completion: @escaping TMBDResult<VideosResponse>) {
            tmdb.fetchObject(ofType: VideosResponse.self, endpoint: Movies.videos(movieId: movieId), completion: completion)
        }

        /// Get a list of translations that have been created for a movie.
        public func translations(for movieId: Int, completion: @escaping TMBDResult<TranslationsResponse>) {
            tmdb.fetchObject(ofType: TranslationsResponse.self, endpoint: Movies.translations(movieId: movieId), completion: completion)
        }

        /// Get a list of recommended movies for a movie.
        public func recommendations(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.recommendations(movieId: movieId, pageNumber: pageNumber), completion: completion)
        }

        /// Get a list of similar movies. This is not the same as the "Recommendation" system you see on the website.
        /// These items are assembled by looking at keywords and genres.
        public func similarMovies(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.similarMovies(movieId: movieId, pageNumber: pageNumber), completion: completion)
        }

        /// Get the user reviews for a movie.
        public func reviews(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<ReviewsResponse>) {
            tmdb.fetchObject(ofType: ReviewsResponse.self, endpoint: Movies.reviews(movieId: movieId, pageNumber: pageNumber), completion: completion)
        }

        /// Get a list of lists that this movie belongs to.
        public func lists(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<ListsResponse>) {
            tmdb.fetchObject(ofType: ListsResponse.self, endpoint: Movies.lists(movieId: movieId, pageNumber: pageNumber), completion: completion)
        }

        /// Get the most newly created movie. This is a live response and will continuously change
        ///
        /// - Parameter completion: Result of `Movie` or `TMDBError`
        public func latest(completion: @escaping TMBDResult<Movie>) {
            tmdb.fetchObject(ofType: Movie.self, endpoint: Movies.latest, completion: completion)
        }

        /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
        /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
        ///
        /// - Parameters:
        ///   - pageNumber: Pagenumber
        ///   - completion: Result of `NowPlayingMoviesResponse` or `TMDBError`
        public func nowPlaying(pageNumber: PageNumber, completion: @escaping TMBDResult<NowPlayingMoviesResponse>) {
            tmdb.fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.nowPlaying(pageNumber: pageNumber), completion: completion)
        }

        /// Get the top rated movies on TMDb.
        public func topRated(pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.topRated(pageNumber: pageNumber), completion: completion)
        }

        /// Get a list of the current popular movies on TMDb. This list updates daily
        ///
        /// - Parameters:
        ///   - pageNumber: Page
        ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
        public func popular(pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
            tmdb.fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.popular(pageNumber: pageNumber), completion: completion)
        }

        public func rateMovie(_ movieId: Int, rating: Double, completion: @escaping TMBDResult<StatusResponse>) {
            guard let sessionProvider = sessionProvider else {
                return completion(.failure(.sessionIdMissing))
            }
            tmdb.authenticatedRequestAndParse(Movies.rateMovie(rating: rating, movieId: movieId, sessionId: sessionProvider.sessionId), completion: completion)
        }

        public func deleteRating(of movieId: Int, completion: @escaping TMBDResult<StatusResponse>) {
            guard let sessionProvider = sessionProvider else {
                return completion(.failure(.sessionIdMissing))
            }

            tmdb.authenticatedRequestAndParse(Movies.deleteRating(movieId: movieId, sessionId: sessionProvider.sessionId), completion: completion)
        }

        /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
        /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
        ///
        /// - Parameters:
        ///   - pageNumber: Pagenumber
        ///   - completion: Result of `NowPlayingMoviesResponse` or `TMDBError`
        public func upcoming(pageNumber: PageNumber, completion: @escaping TMBDResult<NowPlayingMoviesResponse>) {
            tmdb.fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.upcoming(pageNumber: pageNumber), completion: completion)
        }
    }
}
