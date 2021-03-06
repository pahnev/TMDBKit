//
//  TMDB+List.swift
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
        /// - Parameter listId: Id of the list.
        public func details(for listId: String, completion: @escaping TMDBResult<ListDetails>) {
            tmdb.authenticatedRequestAndParse(Lists.details(listId: listId), completion: completion)
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
        public func createWith(name: String, description: String?, language: String?, completion: @escaping TMDBResult<ListCreateResponse>) {
            let list = Lists.List(name: name, description: description ?? "", language: language ?? "")
            tmdb.authenticatedRequestAndParse(Lists.createList(list: list), completion: completion)
        }

        /// Add a movie to a list.
        public func addMovie(movieId: Int, to listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.addMovie(listId: listId, mediaId: movieId), completion: completion)
        }

        /// Remove a movie from a list.
        public func removeMovie(movieId: Int, from listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.removeMovie(listId: listId, mediaId: movieId), completion: completion)
        }

        /// Clear all of the items from a list.
        public func clear(listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.clearList(listId: listId), completion: completion)
        }

        /// Delete a list.
        public func delete(listId: String, completion: @escaping TMDBResult<ListModificationResponse>) {
            tmdb.authenticatedRequestAndParse(Lists.deleteList(listId: listId), completion: completion)
        }
    }
}
