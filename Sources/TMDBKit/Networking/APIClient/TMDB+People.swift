//
//  TMDB+People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

extension TMDB {

    public struct PeopleEndpoints {
        let tmdb: TMDB

        /// Get the primary person details by id.
        public func details(for personId: Int, appending details: [DetailsAppendable]?, completion: @escaping TMBDResult<PersonDetailsResponse>) {
            // TODO Return appended details, lang
            tmdb.fetchObject(ofType: PersonDetailsResponse.self, endpoint: People.details(personId: personId, append: details), completion: completion)
        }

        /// Get the changes for a person. By default only the last 24 hours are returned.
        /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
        public func changes(for personId: Int, completion: @escaping TMBDResult<ChangesResponse>) {
            // TODO lang, pagination & start and end date query
            tmdb.fetchObject(ofType: ChangesResponse.self, endpoint: People.changes(personId: personId), completion: completion)
        }

        /// Get the movie credits for a person.
        public func movieCredits(for personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
            // TODO Lang query
            tmdb.fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.movieCredits(personId: personId), completion: completion)
        }

        /// Get the TV show credits for a person.
        /// You can query for some extra details about the credit with the `TMDB.Credits.details` method.
        public func tvCredits(for personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
            tmdb.fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.tvCredits(personId: personId), completion: completion)
        }

        /// Get the movie and TV credits together in a single response.
        public func combinedCredits(for personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
            // TODO Lang query
            tmdb.fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.combinedCredits(personId: personId), completion: completion)
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
        public func externalIds(for personId: Int, completion: @escaping TMBDResult<ExternalIds>) {
            // TODO Lang query
            tmdb.fetchObject(ofType: ExternalIds.self, endpoint: People.externalIds(personId: personId), completion: completion)
        }

        /// Get the images for a person.
        public func images(for personId: Int, completion: @escaping TMBDResult<PersonImageResponse>) {
            tmdb.fetchObject(ofType: PersonImageResponse.self, endpoint: People.images(personId: personId), completion: completion)
        }

        /// Get the images that this person has been tagged in.
        public func taggedImages(for personId: Int, completion: @escaping TMBDResult<TaggedImageResponse>) {
            // TODO lang, pagination
            tmdb.fetchObject(ofType: TaggedImageResponse.self, endpoint: People.taggedImages(personId: personId), completion: completion)
        }

        /// Get a list of translations that have been created for a person.
        public func translations(for personId: Int, completion: @escaping TMBDResult<PersonTranslationResponse>) {
            // TODO Lang query
            tmdb.fetchObject(ofType: PersonTranslationResponse.self, endpoint: People.translations(personId: personId), completion: completion)
        }

        /// Get the most newly created person. This is a live response and will continuously change.
        public func latest(completion: @escaping TMBDResult<PersonDetailsResponse>) {
            // TODO Lang query
            tmdb.fetchObject(ofType: PersonDetailsResponse.self, endpoint: People.latest, completion: completion)
        }

        /// Get the list of popular people on TMDb. This list updates daily.
        public func popular(completion: @escaping TMBDResult<PopularPersonResponse>) {
            // TODO lang, pagination
            tmdb.fetchObject(ofType: PopularPersonResponse.self, endpoint: People.popular, completion: completion)
        }
    }
}
