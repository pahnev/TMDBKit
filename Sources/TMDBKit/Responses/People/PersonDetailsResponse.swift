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
    public var deathDay: String? {
        deathday
    }

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
    /// Deprecated for person append requests: no matching person resource exists.
    public let reviews: AppendedReviews?

    /// Nil unless appended to the API call.
    /// Deprecated for person append requests: no matching person resource exists.
    public let videos: AppendedVideos?

    /// Nil unless appended to the API call.
    @available(*, deprecated, message: "Person images use profiles; use profileImages. This compatibility field is nil.")
    public var images: AppendedImages? {
        nil
    }

    public let profileImages: AppendedPersonImages?

    /// Nil unless appended to the API call.
    /// Compatibility alias for the documented combined_credits resource.
    public var credits: AppendedPersonCredits? {
        combinedCredits
    }

    public let movieCredits: AppendedPersonCredits?
    public let tvCredits: AppendedPersonCredits?
    public let combinedCredits: AppendedPersonCredits?

    /// Nil unless appended to the API call.
    /// Deprecated for person append requests: no matching person resource exists.
    public let recommendations: AppendedRecommendations?

    /// Nil unless appended to the API call.
    /// Deprecated for person append requests: no matching person resource exists.
    public let similar: PopularMoviesResponse?

    /// Nil unless appended to the API call.
    @available(*, deprecated, message: "Use personTranslations for person data. The movie-shaped compatibility projection is unavailable and nil.")
    public var translations: AppendedTranslations? {
        nil
    }

    public let personTranslations: [PersonTranslation]?

    private struct PersonTranslations: CodableEquatable {
        let translations: [PersonTranslation]
    }

    private enum CodingKeys: String, CodingKey {
        case birthday, knownForDepartment, deathday, id, name, alsoKnownAs, gender
        case biography, popularity, placeOfBirth, profilePath, adult, imdbId, homepage
        case reviews, videos, images, movieCredits, tvCredits, combinedCredits
        case recommendations, similar, translations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: .knownForDepartment)
        deathday = try container.decodeIfPresent(String.self, forKey: .deathday)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        alsoKnownAs = try container.decode([String].self, forKey: .alsoKnownAs)
        gender = try container.decode(Int.self, forKey: .gender)
        biography = try container.decode(String.self, forKey: .biography)
        popularity = try container.decode(Double.self, forKey: .popularity)
        placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth)
        profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
        adult = try container.decode(Bool.self, forKey: .adult)
        imdbId = try container.decodeIfPresent(String.self, forKey: .imdbId)
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        reviews = try container.decodeIfPresent(AppendedReviews.self, forKey: .reviews)
        videos = try container.decodeIfPresent(AppendedVideos.self, forKey: .videos)
        recommendations = try container.decodeIfPresent(AppendedRecommendations.self, forKey: .recommendations)
        similar = try container.decodeIfPresent(PopularMoviesResponse.self, forKey: .similar)
        movieCredits = try container.decodeIfPresent(AppendedPersonCredits.self, forKey: .movieCredits)
        tvCredits = try container.decodeIfPresent(AppendedPersonCredits.self, forKey: .tvCredits)
        combinedCredits = try container.decodeIfPresent(AppendedPersonCredits.self, forKey: .combinedCredits)
        profileImages = try container.decodeIfPresent(AppendedPersonImages.self, forKey: .images)
        personTranslations = try container.decodeIfPresent(PersonTranslations.self, forKey: .translations)?.translations
    }

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
        case movieCredits = "movie_credits"
        case tvCredits = "tv_credits"
        case combinedCredits = "combined_credits"
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
        try container.encodeIfPresent(profileImages, forKey: .images)
        try container.encodeIfPresent(movieCredits, forKey: .movieCredits)
        try container.encodeIfPresent(tvCredits, forKey: .tvCredits)
        try container.encodeIfPresent(combinedCredits, forKey: .combinedCredits)
        try container.encodeIfPresent(recommendations, forKey: .recommendations)
        try container.encodeIfPresent(similar, forKey: .similar)
        try container.encodeIfPresent(personTranslations.map { PersonTranslations(translations: $0) }, forKey: .translations)
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
