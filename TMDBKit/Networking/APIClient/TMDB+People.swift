//
//  TMDB+People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

extension TMDB {
    public func getPersonImages(personId: Int, completion: @escaping TMBDResult<PersonImageResponse>) {
        fetchObject(ofType: PersonImageResponse.self, endpoint: People.images(personId: personId), completion: completion)
    }
}
