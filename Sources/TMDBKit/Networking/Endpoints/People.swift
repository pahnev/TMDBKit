//
//  People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

enum People: Endpoint {
    case details(personId: Int, language: String?, append: [DetailsAppendable]?)
    case changes(personId: Int, pageNumber: PageNumber = 1, startDate: String? = nil, endDate: String? = nil)
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
            return people
                .appendingPathComponent("\(personId)")
                .appendingDetails(append, language: language, person: true)

        case .changes(let personId, let pageNumber, let startDate, let endDate):
            let dates = [URLQueryItem(name: "start_date", value: startDate),
                         URLQueryItem(name: "end_date", value: endDate)].filter { $0.value != nil }
            return people
                .appendingPathComponent("\(personId)/changes")
                .appendingPage(pageNumber)
                .appendingQueryItems(dates)
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
        case .externalIds(let personId, _):
            return people
                .appendingPathComponent("\(personId)/external_ids")
        case .images(let personId):
            return people.appendingPathComponent("\(personId)/images")
        case .taggedImages(let personId, let pageNumber, _):
            return people
                .appendingPathComponent("\(personId)/tagged_images")
                .appendingPage(pageNumber)
        case .translations(let personId, _):
            return people
                .appendingPathComponent("\(personId)/translations")
        case .latest(_):
            return people
                .appendingPathComponent("latest")
        case .popular(let pageNumber, let language):
            return people
                .appendingPathComponent("popular")
                .appendingPage(pageNumber)
                .appendingLanguage(language)
        }
    }
}
