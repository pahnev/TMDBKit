//
//  TMDB+Lists.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 13.4.2021.
//  Copyright © 2020 Pahnev. All rights reserved.
//

import Foundation

public extension TMDB {
    struct ListEndpoints {
        let tmdb: TMDB

        /// Get the details of a list.
        /// - Parameters:
        ///   - listId: Id of the list.
        ///   - language: A language string in ISO 639-1 format, to get translated data for the fields that support it. Defaults to `en-US`.
        ///   - completion: Result of `ListDetails` or `TMDBError`.
        public func details(for listId: String, language: String? = nil, completion: @escaping TMDBResult<ListDetails>) {
            tmdb.authenticatedRequestAndParse(Lists.details(listId: listId, language: language), completion: completion)
        }

        /// You can use this method to check if a movie has already been added to the list.
        /// - Parameters:
        ///   - itemId: Id of the item to check in the list.
        ///   - listId: Id of the list where to check.
        ///   - completion: Result of `ListItemStatus` or `TMDBError`.
        public func itemStatus(itemId: Int, listId: String, completion: @escaping TMDBResult<ListItemStatus>) {
            tmdb.authenticatedRequestAndParse(Lists.itemStatus(listId: listId, movieId: itemId), completion: completion)
        }

        /// Create a list.
        /// - Parameters:
        ///   - name: The name of the list.
        ///   - description: The description of the list.
        ///   - language: The language of the list.
        ///   - completion: Result of `ListCreateResponse` or `TMDBError`.
        public func createWith(name: String, description: String?, language: String?, completion: @escaping TMDBResult<ListCreateResponse>) {
            let list = Lists.List(name: name, description: description ?? "", language: language ?? "")
            tmdb.authenticatedRequestAndParse(Lists.createList(list: list), completion: completion)
        }

        /// Add a movie to a list.
        /// - Parameters:
        ///   - movieId: The `id` of the movie to be added.
        ///   - listId: The `id` of the list where the movie should be added to.
        ///   - completion: Result of `ListModificationResponse` or `TMDBError`.
        public func addMovie(movieId: Int, to listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.addMovie(listId: listId, mediaId: movieId), completion: completion)
        }

        /// Remove a movie from a list
        /// - Parameters:
        ///   - movieId: The `id` of the movie to be removed.
        ///   - listId: The `id` of the list where the movie currently is.
        ///   - completion: Result of `ListModificationResponse` or `TMDBError`.
        public func removeMovie(movieId: Int, from listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.removeMovie(listId: listId, mediaId: movieId), completion: completion)
        }

        /// Clear all of the items from a list
        /// - Parameters:
        ///   - listId: The `id` of the list to be cleared.
        ///   - completion: Result of `ListModificationResponse` or `TMDBError`.
        public func clear(listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.clearList(listId: listId), completion: completion)
        }

        /// Delete a list.
        /// - Parameters:
        ///   - listId: The `id` of the list to be deleted.
        ///   - completion: Result of `ListModificationResponse` or `TMDBError`.
        public func delete(listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.deleteList(listId: listId), completion: completion)
        }
    }
}
