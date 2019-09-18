//
//  People.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 28/08/2018.
//

import Foundation

enum People: Endpoint {
    case details(personId: Int, append: [DetailsAppendable]?)
    case changes(personId: Int)
    case movieCredits(personId: Int)
    case tvCredits(personId: Int)
    case combinedCredits(personId: Int)
    case externalIds(personId: Int)
    case images(personId: Int)
    case taggedImages(personId: Int)
    case translations(personId: Int)
    case latest
    case popular

    var httpMethod: HTTPMethod {
        switch self {
        case .details,
             .changes,
             .movieCredits,
             .tvCredits,
             .combinedCredits,
             .externalIds,
             .images,
             .taggedImages,
             .translations,
             .latest,
             .popular:
            return .GET
        }
    }

    var httpBody: Data? {
        switch self {
        case .details,
             .changes,
             .movieCredits,
             .tvCredits,
             .combinedCredits,
             .externalIds,
             .images,
             .taggedImages,
             .translations,
             .latest,
             .popular:
            return nil
        }
    }

    var requestHeaders: [String : String] {
        switch self {
        case .details,
             .changes,
             .movieCredits,
             .tvCredits,
             .combinedCredits,
             .externalIds,
             .images,
             .taggedImages,
             .translations,
             .latest,
             .popular:
            return [:]
        }
    }

    var url: URL {
        let people = baseURL.appendingPathComponent("person")

        switch self {
        case .details(let params):
            let peopleDetails = people.appendingPathComponent("\(params.personId)")
            if let append = params.append {
                let appendEndpoints = append.map { $0.name }.joined(separator: ",")
                let appendToResponse = URLQueryItem(name: "append_to_response", value: appendEndpoints)
                let query = append.compactMap { $0.queryItem }
                return peopleDetails
                    .appendingQueryItem(appendToResponse)
                    .appendingQueryItems(query)
            }
            return peopleDetails
        case .changes(let personId):
            return people.appendingPathComponent("\(personId)/changes")
        case .movieCredits(let personId):
            return people.appendingPathComponent("\(personId)/movie_credits")
        case .tvCredits(let personId):
            return people.appendingPathComponent("\(personId)/tv_credits")
        case .combinedCredits(let personId):
            return people.appendingPathComponent("\(personId)/combined_credits")
        case .externalIds(let personId):
            return people.appendingPathComponent("\(personId)/external_ids")
        case .images(let personId):
            return people.appendingPathComponent("\(personId)/images")
        case .taggedImages(let personId):
            return people.appendingPathComponent("\(personId)/tagged_images")
        case .translations(let personId):
            return people.appendingPathComponent("\(personId)/translations")
        case .latest:
            return people.appendingPathComponent("latest")
        case .popular:
            return people.appendingPathComponent("popular")
        }
    }

}
