//
//  PersonDetailsResponse.swift
//
//
//  Created by Pahnev, Kirill on 14/11/2019.
//

import Foundation

public struct PersonDetailsResponse: CodableEquatable {
    public let birthday: String?
    public let knownForDepartment: String?
    public let deathday: String?
    @available(*, deprecated, message: "Use deathday, the canonical API key")
    public var deathDay: String? { deathday }
    public let id: Int
    public let name: String
    public let alsoKnownAs: [String]
    public let gender: Int
    public let biography: String
    public let popularity: Double
    public let placeOfBirth: String?
    public let profilePath: String?
    public let adult: Bool
    public let imdbId: String?
    public let homepage: String?

    /// Nil unless appended to the API call.
    public let reviews: AppendedReviews?

    /// Nil unless appended to the API call.
    public let videos: AppendedVideos?

    /// Nil unless appended to the API call.
    public let images: AppendedImages?

    /// Nil unless appended to the API call.
    public let credits: AppendedPersonCredits?

    /// Nil unless appended to the API call.
    public let recommendations: AppendedRecommendations?

    /// Nil unless appended to the API call.
    public let similar: PopularMoviesResponse?

    /// Nil unless appended to the API call.
    public let translations: AppendedTranslations?
    private enum WireKeys: String, CodingKey {
        case birthday
        case knownForDepartment = "known_for_department"
        case deathday
        case id
        case name
        case alsoKnownAs = "also_known_as"
        case gender
        case biography
        case popularity
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
        case adult
        case imdbId = "imdb_id"
        case homepage
        case reviews
        case videos
        case images
        case credits
        case recommendations
        case similar
        case translations
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WireKeys.self)
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(knownForDepartment, forKey: .knownForDepartment)
        try container.encodeIfPresent(deathday, forKey: .deathday)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(alsoKnownAs, forKey: .alsoKnownAs)
        try container.encode(gender, forKey: .gender)
        try container.encode(biography, forKey: .biography)
        try container.encode(popularity, forKey: .popularity)
        try container.encodeIfPresent(placeOfBirth, forKey: .placeOfBirth)
        try container.encodeIfPresent(profilePath, forKey: .profilePath)
        try container.encode(adult, forKey: .adult)
        try container.encodeIfPresent(imdbId, forKey: .imdbId)
        try container.encodeIfPresent(homepage, forKey: .homepage)
        try container.encodeIfPresent(reviews, forKey: .reviews)
        try container.encodeIfPresent(videos, forKey: .videos)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(credits, forKey: .credits)
        try container.encodeIfPresent(recommendations, forKey: .recommendations)
        try container.encodeIfPresent(similar, forKey: .similar)
        try container.encodeIfPresent(translations, forKey: .translations)
    }

}

public struct PopularPersonResponse: CodableEquatable {
    public let page: Int
    public let totalResults: Int
    public let totalPages: Int
    public let results: [PopularPerson]
}

public struct PopularPerson: CodableEquatable {
    public let originalName: String?
    public let mediaType: String?
    public let popularity: Double
    public let knownForDepartment: String?
    public let gender: Int
    public let id: Int
    public let profilePath: String?
    public let adult: Bool
    public let knownFor: [Media]
    public let name: String
}
