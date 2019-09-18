import Foundation

/// Represents the values that can be passed into `details` endpoints. This makes it possible to make sub requests within the same namespace in a single HTTP request.
///
/// - videos: The language code in ISO-639-1 format, for specifying in which language the videos should be.
/// - images: For specifying in which language the images should be, add the language codes in ISO 639-1 format.
///           Defaults to [en,null], which will return all images that match English and those that haven't been set yet (null)
public enum DetailsAppendable {
    case reviews(language: String?)
    case videos(language: String?)

    case images(languages: [String]?)

    var name: String {
        switch self {
        case .reviews: return "reviews"
        case .videos: return "videos"
        case .images: return "images"
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
        }
    }

    var debugDescription: String {
        return "\(name)_\(String(describing: queryItem?.name))_\(String(describing: queryItem?.value))"
    }
}
