//
//  TMDB+People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

extension TMDB {

    /// Get the primary person details by id.
    public func getPersonDetails(personId: Int, appending details: [DetailsAppendable]?, completion: @escaping TMBDResult<PersonDetailsResponse>) {
        // TODO Return appended details, lang
        fetchObject(ofType: PersonDetailsResponse.self, endpoint: People.details(personId: personId, append: details), completion: completion)
    }

    /// Get the changes for a person. By default only the last 24 hours are returned.
    /// You can query up to 14 days in a single query by using the start_date and end_date query parameters.
    public func getPersonChanges(personId: Int, completion: @escaping TMBDResult<ChangesResponse>) {
        // TODO lang, pagination & start and end date query
        fetchObject(ofType: ChangesResponse.self, endpoint: People.changes(personId: personId), completion: completion)
    }

    /// Get the movie credits for a person.
    public func getPersonMovieCredits(personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
        // TODO Lang query
        fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.movieCredits(personId: personId), completion: completion)
    }

    /// Get the TV show credits for a person.
    /// You can query for some extra details about the credit with the `TMDB.Credits.details` method.
    public func getPersonTVCredits(personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
        fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.tvCredits(personId: personId), completion: completion)
    }

    /// Get the movie and TV credits together in a single response.
    public func getPersonCombinedCredits(personId: Int, completion: @escaping TMBDResult<PersonCreditsResponse>) {
        // TODO Lang query
        fetchObject(ofType: PersonCreditsResponse.self, endpoint: People.combinedCredits(personId: personId), completion: completion)
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
    public func getPersonExternalIds(personId: Int, completion: @escaping TMBDResult<ExternalIds>) {
        // TODO Lang query
        fetchObject(ofType: ExternalIds.self, endpoint: People.externalIds(personId: personId), completion: completion)
    }

    /// Get the images for a person.
    public func getPersonImages(personId: Int, completion: @escaping TMBDResult<PersonImageResponse>) {
        fetchObject(ofType: PersonImageResponse.self, endpoint: People.images(personId: personId), completion: completion)
    }

    /// Get the images that this person has been tagged in.
    public func getPersonTaggedImages(personId: Int, completion: @escaping TMBDResult<TaggedImageResponse>) {
        // TODO lang, pagination
        fetchObject(ofType: TaggedImageResponse.self, endpoint: People.taggedImages(personId: personId), completion: completion)
    }

    /// Get a list of translations that have been created for a person.
    public func getPersonTranslations(personId: Int, completion: @escaping TMBDResult<PersonTranslationResponse>) {
        // TODO Lang query
        fetchObject(ofType: PersonTranslationResponse.self, endpoint: People.translations(personId: personId), completion: completion)
    }

    /// Get the most newly created person. This is a live response and will continuously change.
    public func getPersonLatest(completion: @escaping TMBDResult<PersonDetailsResponse>) {
        // TODO Lang query
        fetchObject(ofType: PersonDetailsResponse.self, endpoint: People.latest, completion: completion)
    }

    /// Get the list of popular people on TMDb. This list updates daily.
    public func getPersonPopular(completion: @escaping TMBDResult<PopularPersonResponse>) {
        // TODO lang, pagination
        fetchObject(ofType: PopularPersonResponse.self, endpoint: People.popular, completion: completion)
    }
}
