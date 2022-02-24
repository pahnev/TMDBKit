//
//  People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

enum People: Endpoint {
    case details(personId: Int, language: String?, append: [DetailsAppendable]?)
    case changes(personId: Int, pageNumber: PageNumber)
    case movieCredits(personId: Int, language: String?)
    case tvCredits(personId: Int, language: String?)
    case combinedCredits(personId: Int, language: String?)
    case externalIds(personId: Int, language: String?)
    case images(personId: Int)
    case taggedImages(personId: Int, pageNumber: PageNumber, language: String?)
    case translations(personId: Int, language: String?)
    case latest(language: String?)
    case popular(pageNumber: PageNumber, language: String?)

    var url: URL {
        let people = baseURL.appendingPathComponent("person")

        switch self {
        case .details(let personId, let language, let append):
            let peopleDetails = people
                .appendingPathComponent("\(personId)")
                .appendingLanguage(language)
            if let append = append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return peopleDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return peopleDetails
        case .changes(let personId, let pageNumber):
            return people
                .appendingPathComponent("\(personId)/changes")
                .appendingPage(pageNumber)
        case .movieCredits(let personId, let language):
            return people
                .appendingPathComponent("\(personId)/movie_credits")
                .appendingLanguage(language)
        case .tvCredits(let personId, let language):
            return people
                .appendingPathComponent("\(personId)/tv_credits")
                .appendingLanguage(language)
        case .combinedCredits(let personId, let language):
            return people
                .appendingPathComponent("\(personId)/combined_credits")
                .appendingLanguage(language)
        case .externalIds(let personId, let language):
            return people
                .appendingPathComponent("\(personId)/external_ids")
                .appendingLanguage(language)
        case .images(let personId):
            return people.appendingPathComponent("\(personId)/images")
        case .taggedImages(let personId, let pageNumber, let language):
            return people
                .appendingPathComponent("\(personId)/tagged_images")
                .appendingPage(pageNumber)
                .appendingLanguage(language)
        case .translations(let personId, let language):
            return people
                .appendingPathComponent("\(personId)/translations")
                .appendingLanguage(language)
        case .latest(let language):
            return people
                .appendingPathComponent("latest")
                .appendingLanguage(language)
        case .popular(let pageNumber, let language):
            return people
                .appendingPathComponent("popular")
                .appendingPage(pageNumber)
                .appendingLanguage(language)
        }
    }
}
