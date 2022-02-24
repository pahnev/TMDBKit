//
//  TMDB+People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

public extension TMDB {
    struct PeopleEndpoints {
        let tmdb: TMDB

        /// Get the primary person details by id.


        /// Get the primary person details by id.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonDetailsResponse` or `TMDBError`.
        public func details(for personId: Int, language: String? = nil, appending details: [DetailsAppendable]?, completion: @escaping TMDBResult<PersonDetailsResponse>) {
            tmdb.fetchObject(ofType: PersonDetailsResponse.self,
                             endpoint: People.details(personId: personId, language: language, append: details),
                             completion: completion)
        }

        /// Get the changes for a person. By default only the last 24 hours are returned.
        /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.


        /// Get the changes for a person. By default only the last 24 hours are returned.
        /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - pageNumber: The page number to fetch.
        ///   - completion: Result of a `ChangesResponse` or `TMDBError`.
        public func changes(for personId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<ChangesResponse>) {
            // TODO: start and end date query
            tmdb.fetchObject(ofType: ChangesResponse.self,
                             endpoint: People.changes(personId: personId, pageNumber: pageNumber),
                             completion: completion)
        }

        /// Get the movie credits for a person.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonCreditsResponse` or `TMDBError`.
        public func movieCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>) {
            tmdb.fetchObject(ofType: PersonCreditsResponse.self,
                             endpoint: People.movieCredits(personId: personId, language: language),
                             completion: completion)
        }

        /// Get the TV show credits for a person.
        /// You can query for some extra details about the credit with the `TMDB.Credits.details` method.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonCreditsResponse` or `TMDBError`.
        public func tvCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>) {
            tmdb.fetchObject(ofType: PersonCreditsResponse.self,
                             endpoint: People.tvCredits(personId: personId, language: language),
                             completion: completion)
        }

        /// Get the movie and TV credits together in a single response.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonCreditsResponse` or `TMDBError`.
        public func combinedCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>) {
            tmdb.fetchObject(ofType: PersonCreditsResponse.self,
                             endpoint: People.combinedCredits(personId: personId, language: language),
                             completion: completion)
        }

        /// Get the external ids for a person. Currently supports the following external sources.
        ///
        /// | **External Sources** |
        /// | :------------------- |
        /// | IMDB ID              |
        /// | Facebook             |
        /// | Freebase MID         |
        /// | Freebase ID          |
        /// | Instagram            |
        /// | TVRage ID            |
        /// | Twitter              |
        ///
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `ExternalIds` or `TMDBError`.
        public func externalIds(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<ExternalIds>) {
            tmdb.fetchObject(ofType: ExternalIds.self,
                             endpoint: People.externalIds(personId: personId, language: language),
                             completion: completion)
        }

        /// Get the images for a person.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - completion: Result of a `PersonImageResponse` or `TMDBError`.
        public func images(for personId: Int, completion: @escaping TMDBResult<PersonImageResponse>) {
            tmdb.fetchObject(ofType: PersonImageResponse.self, endpoint: People.images(personId: personId), completion: completion)
        }

        /// Get the images that this person has been tagged in.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - pageNumber: The page number to fetch. Defaults to 1 to get the first results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `TaggedImageResponse` or `TMDBError`.
        public func taggedImages(for personId: Int, pageNumber: PageNumber = 1, language: String? = nil, completion: @escaping TMDBResult<TaggedImageResponse>) {
            tmdb.fetchObject(ofType: TaggedImageResponse.self,
                             endpoint: People.taggedImages(personId: personId, pageNumber: pageNumber, language: language),
                             completion: completion)
        }

        /// Get a list of translations that have been created for a person.
        /// - Parameters:
        ///   - personId: The id of the Person.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonTranslationResponse` or `TMDBError`.
        public func translations(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonTranslationResponse>) {
            tmdb.fetchObject(ofType: PersonTranslationResponse.self,
                             endpoint: People.translations(personId: personId, language: language),
                             completion: completion)
        }

        /// Get the most newly created person. This is a live response and will continuously change.
        /// - Parameters:
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PersonDetailsResponse` or `TMDBError`.
        public func latest(in language: String? = nil, completion: @escaping TMDBResult<PersonDetailsResponse>) {
            tmdb.fetchObject(ofType: PersonDetailsResponse.self,
                             endpoint: People.latest(language: language),
                             completion: completion)
        }

        /// Get the list of popular people on TMDb. This list updates daily.
        /// - Parameters:
        ///   - pageNumber: The page number to fetch. Defaults to 1 to get the first results.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of a `PopularPersonResponse` or `TMDBError`.
        public func popular(pageNumber: PageNumber = 1, language: String? = nil, completion: @escaping TMDBResult<PopularPersonResponse>) {
            tmdb.fetchObject(ofType: PopularPersonResponse.self,
                             endpoint: People.popular(pageNumber: pageNumber, language: language),
                             completion: completion)
        }
    }
}
