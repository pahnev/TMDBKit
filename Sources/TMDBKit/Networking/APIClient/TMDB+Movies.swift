//
//  TMDB+Movies.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

extension TMDB {
    /// Get the primary information about a movie
    /// Supports append_to_response. Read more about this here https://developers.themoviedb.org/3/getting-started/append-to-response.
    ///
    /// - Parameters:
    ///   - movieId: Movie
    ///   - completion: Result of `Movie` or `TMDBError`
    public func getMovieDetails(for movieId: Int, appending details: [DetailsAppendable]?, completion: @escaping TMBDResult<Movie>) {
        fetchObject(ofType: Movie.self, endpoint: Movies.details(movieId: movieId, append: details), completion: completion)
    }

    /// Get all of the alternative titles for a movie
    public func getAlternativeMovieTitles(movieId: Int, completion: @escaping TMBDResult<AlternativeTitlesResponse>) {
        fetchObject(ofType: AlternativeTitlesResponse.self, endpoint: Movies.alternativeTitles(movieId: movieId), completion: completion)
    }

    /// Get the changes for a movie. By default only the last 24 hours are returned.
    /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
    ///
    /// - Parameters:
    ///   - movieId: Movie
    ///   - completion: Closure
    public func getMovieChanges(movieId: Int, completion: @escaping TMBDResult<ChangesResponse>) {
        fetchObject(ofType: ChangesResponse.self, endpoint: Movies.changes(movieId: movieId), completion: completion)
    }

    /// Get the cast and crew for a movie.
    public func getMovieCredits(movieId: Int, completion: @escaping TMBDResult<CreditsResponse>) {
        fetchObject(ofType: CreditsResponse.self, endpoint: Movies.credits(movieId: movieId), completion: completion)
    }

    /// Get the external ids for a movie. We currently support the following external sources.
    ///
    /// | **Media Databases** | **Social IDs** |
    /// | :-----------------: | :------------: |
    /// |       IMDb ID       |    Facebook    |
    /// |                     |   Instagram    |
    /// |                     |    Twitter     |
    ///
    public func getExternalIds(movieId: Int, completion: @escaping TMBDResult<ExternalIds>) {
        fetchObject(ofType: ExternalIds.self, endpoint: Movies.externalIds(movieId: movieId), completion: completion)
    }

    /// Get the images that belong to a movie.
    /// Querying images with a `language` parameter will filter the results. If you want to include a fallback language (especially useful for backdrops) you can use the `include_image_language` parameter. This should be a comma seperated value like so: `include_image_language=en,null`.
    public func getMovieImages(movieId: Int, completion: @escaping TMBDResult<ImagesResponse>) {
        fetchObject(ofType: ImagesResponse.self, endpoint: Movies.images(movieId: movieId), completion: completion)
    }

    /// Get the keywords that have been added to a movie
    public func getMovieKeywords(movieId: Int, completion: @escaping TMBDResult<KeywordsResponse>) {
        fetchObject(ofType: KeywordsResponse.self, endpoint: Movies.keywords(movieId: movieId), completion: completion)
    }

    /// Get the release date along with the certification for a movie.
    /// 1. Release dates support different types:
    /// 2. Premiere
    /// 3. Theatrical (limited)
    /// 4. Theatrical
    /// 5. Digital
    /// 6. Physical
    /// 7. TV
    public func getMovieReleaseDates(movieId: Int, completion: @escaping TMBDResult<ReleaseDatesResponse>) {
        fetchObject(ofType: ReleaseDatesResponse.self, endpoint: Movies.releaseDates(movieId: movieId), completion: completion)
    }

    /// Get the videos that have been added to a movie.
    public func getMovieVideos(movieId: Int, completion: @escaping TMBDResult<VideosResponse>) {
        fetchObject(ofType: VideosResponse.self, endpoint: Movies.videos(movieId: movieId), completion: completion)
    }

    /// Get a list of translations that have been created for a movie.
    public func getMovieTranslations(movieId: Int, completion: @escaping TMBDResult<TranslationsResponse>) {
        fetchObject(ofType: TranslationsResponse.self, endpoint: Movies.translations(movieId: movieId), completion: completion)
    }

    /// Get a list of recommended movies for a movie.
    public func getMovieRecommendations(movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
        fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.recommendations(movieId: movieId, pageNumber: pageNumber), completion: completion)
    }

    /// Get a list of similar movies. This is not the same as the "Recommendation" system you see on the website.
    /// These items are assembled by looking at keywords and genres.
    public func getSimilarMovies(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
        fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.similarMovies(movieId: movieId, pageNumber: pageNumber), completion: completion)
    }

    /// Get the user reviews for a movie.
    public func getReviews(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<ReviewsResponse>) {
        fetchObject(ofType: ReviewsResponse.self, endpoint: Movies.reviews(movieId: movieId, pageNumber: pageNumber), completion: completion)
    }

    /// Get a list of lists that this movie belongs to.
    public func getLists(for movieId: Int, pageNumber: PageNumber, completion: @escaping TMBDResult<ListsResponse>) {
        fetchObject(ofType: ListsResponse.self, endpoint: Movies.lists(movieId: movieId, pageNumber: pageNumber), completion: completion)
    }

    /// Get the most newly created movie. This is a live response and will continuously change
    ///
    /// - Parameter completion: Result of `Movie` or `TMDBError`
    public func getLatestMovie(completion: @escaping TMBDResult<Movie>) {
        fetchObject(ofType: Movie.self, endpoint: Movies.latest, completion: completion)
    }

    /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
    /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
    ///
    /// - Parameters:
    ///   - pageNumber: Pagenumber
    ///   - completion: Result of `NowPlayingMoviesResponse` or `TMDBError`
    public func getNowPlayingMovies(pageNumber: PageNumber, completion: @escaping TMBDResult<NowPlayingMoviesResponse>) {
        fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.nowPlaying(pageNumber: pageNumber), completion: completion)
    }

    /// Get the top rated movies on TMDb.
    public func getTopRatedMovies(pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
        fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.topRated(pageNumber: pageNumber), completion: completion)
    }

    /// Get a list of the current popular movies on TMDb. This list updates daily
    ///
    /// - Parameters:
    ///   - pageNumber: Page
    ///   - completion: Result of `PopularMoviesResponse` or `TMDBError`
    public func getPopularMovies(pageNumber: PageNumber, completion: @escaping TMBDResult<PopularMoviesResponse>) {
        fetchObject(ofType: PopularMoviesResponse.self, endpoint: Movies.popular(pageNumber: pageNumber), completion: completion)
    }

    public func rateMovie(_ movieId: Int, rating: Double, completion: @escaping TMBDResult<StatusResponse>) {
        guard let sessionProvider = sessionProvider else {
            return completion(.failure(.sessionIdMissing))
        }
        authenticatedRequestAndParse(Movies.rateMovie(rating: rating, movieId: movieId, sessionId: sessionProvider.sessionId), completion: completion)
    }

    public func deleteRating(of movieId: Int, completion: @escaping TMBDResult<StatusResponse>) {
        guard let sessionProvider = sessionProvider else {
            return completion(.failure(.sessionIdMissing))
        }

        authenticatedRequestAndParse(Movies.deleteRating(movieId: movieId, sessionId: sessionProvider.sessionId), completion: completion)
    }

    /// Get a list of movies in theatres. This is a release type query that looks for all movies that have a release type of 2 or 3 within the specified date range.
    /// You can optionally specify a region prameter which will narrow the search to only look for theatrical release dates within the specified country.
    ///
    /// - Parameters:
    ///   - pageNumber: Pagenumber
    ///   - completion: Result of `NowPlayingMoviesResponse` or `TMDBError`
    public func getUpcomingMovies(pageNumber: PageNumber, completion: @escaping TMBDResult<NowPlayingMoviesResponse>) {
        fetchObject(ofType: NowPlayingMoviesResponse.self, endpoint: Movies.upcoming(pageNumber: pageNumber), completion: completion)
    }
}
