import Foundation

/// Represents the values that can be passed into `details` endpoints. This makes it possible to make sub requests within the same namespace in a single HTTP request.
///
/// Movie/TV accept the original seven cases. Person accepts images, translations,
/// movieCredits, tvCredits and combinedCredits; legacy credits aliases combinedCredits.
/// Person reviews, videos, similar and recommendations are deprecated unsupported selections
/// and are omitted. Person credit cases are omitted for movie/TV.
/// Language is shared across the request: explicit details language wins, otherwise the
/// first supported appended language wins. Image-language values merge in input order.
///
/// - videos: The language code in ISO-639-1 format, for specifying in which language the videos should be.
/// - images: For specifying in which language the images should be, add the language codes in ISO 639-1 format.
///           Use ["en", "null"] for English and untagged images. Nil omits the image-language query.
public enum DetailsAppendable {
    case reviews(language: String?)
    case videos(language: String?)
    case images(languages: [String]?)
    case credits
    case similar
    case recommendations
    case translations
    /// Person-only credit resources.
    case movieCredits
    case tvCredits
    case combinedCredits

    var name: String {
        switch self {
        case .reviews: return "reviews"
        case .videos: return "videos"
        case .images: return "images"
        case .credits: return "credits"
        case .similar: return "similar"
        case .recommendations: return "recommendations"
        case .translations: return "translations"
        case .movieCredits: return "movie_credits"
        case .tvCredits: return "tv_credits"
        case .combinedCredits: return "combined_credits"
        }
    }

    var queryItem: URLQueryItem? {
        switch self {
        case .reviews(let language):
            guard let language = language else { return nil }
            return URLQueryItem(name: "language", value: language)
        case .videos(let language):
            guard let language = language else { return nil }
            return URLQueryItem(name: "language", value: language)
        case .images(let languages):
            guard let languages = languages else { return nil }
            return URLQueryItem(name: "include_image_language", value: languages.joined(separator: ","))
        case .credits, .similar, .recommendations, .translations, .movieCredits, .tvCredits, .combinedCredits:
            return nil
        }
    }

    var debugDescription: String {
        return "\(name)_\(String(describing: queryItem?.name))_\(String(describing: queryItem?.value))"
    }

    static var allCases: [DetailsAppendable] {
        return [
            .images(languages: nil),
            .reviews(language: nil),
            .videos(language: nil),
            .credits,
            .similar,
            .recommendations,
            .translations
        ]
    }
}

/// All append options apply to a single request namespace and shared query string.
extension URL {
    func appendingDetails(_ append: [DetailsAppendable]?, language: String?, person: Bool = false) -> URL {
        var url = appendingLanguage(language)
        guard let append = append else { return url }
        var names: [String] = []
        var queries: [URLQueryItem] = []
        var imageLanguages: [String] = []
        var hasImageLanguages = false
        var selectedLanguage = language
        for item in append {
            let name: String
            if person {
                switch item {
                case .credits: name = "combined_credits"
                case .images, .translations, .movieCredits, .tvCredits, .combinedCredits: name = item.name
                case .reviews, .videos, .similar, .recommendations: continue
                }
            } else {
                switch item {
                case .movieCredits, .tvCredits, .combinedCredits: continue
                default: name = item.name
                }
            }
            if !names.contains(name) {
                names.append(name)
            }
            switch item {
            case .reviews(let value), .videos(let value):
                if selectedLanguage == nil {
                    selectedLanguage = value
                }
            case .images(let values):
                if let values = values {
                    hasImageLanguages = true
                    for value in values where !imageLanguages.contains(value) {
                        imageLanguages.append(value)
                    }
                }
            default: break
            }
        }
        if !names.isEmpty {
            url = url.appendingQueryItem(named: "append_to_response", value: names.joined(separator: ","))
        }
        if language == nil, let selectedLanguage = selectedLanguage {
            queries.append(URLQueryItem(name: "language", value: selectedLanguage))
        }
        if hasImageLanguages {
            queries.append(URLQueryItem(name: "include_image_language", value: imageLanguages.joined(separator: ",")))
        }
        return url.appendingQueryItems(queries)
    }
}
