import XCTest
import TMDBKit

final class PublicMethodCompatibilityTests: TMDBTestCase {
    func testOriginalFullMethodNamesRetainTheirFunctionTypes() {
        let _: (Int, @escaping TMDBResult<AccountState>) -> Void = tmdb.movies.accountStates(for:completion:)
        let _: (Int, String?, @escaping TMDBResult<AccountState>) -> Void = tmdb.tv.accountStates(for:language:completion:)
        let _: (Int, Double, @escaping TMDBResult<StatusResponse>) -> Void = tmdb.movies.rateMovie(_:rating:completion:)
        let _: (Int, Double, @escaping TMDBResult<StatusResponse>) -> Void = tmdb.tv.rateShow(_:rating:completion:)
        let _: (Int, @escaping TMDBResult<StatusResponse>) -> Void = tmdb.movies.deleteRating(of:completion:)
        let _: (Int, @escaping TMDBResult<StatusResponse>) -> Void = tmdb.tv.deleteRating(of:completion:)
        let _: (Int, @escaping TMDBResult<ChangesResponse>) -> Void = tmdb.movies.changes(for:completion:)
        let _: (Int, PageNumber, @escaping TMDBResult<TVChangesResponse>) -> Void = tmdb.tv.changes(for:pageNumber:completion:)
        let _: (Int, PageNumber, @escaping TMDBResult<ChangesResponse>) -> Void = tmdb.people.changes(for:pageNumber:completion:)
        let _: (Int, String?, @escaping TMDBResult<ImagesResponse>) -> Void = tmdb.movies.images(for:language:completion:)
        let _: (Int, String?, @escaping TMDBResult<ImagesResponse>) -> Void = tmdb.tv.images(for:language:completion:)
        let _: (Int, String?, @escaping TMDBResult<VideosResponse>) -> Void = tmdb.tv.videos(for:language:completion:)
        let _: (PageNumber, String?, @escaping TMDBResult<SimilarShowsResponse>) -> Void = tmdb.tv.airingToday(pageNumber:language:completion:)
        let _: (PageNumber, String?, @escaping TMDBResult<SimilarShowsResponse>) -> Void = tmdb.tv.onTheAir(pageNumber:language:completion:)
        let _: (MediaType, TimeWindow, @escaping TMDBResult<TrendingResponse>) -> Void = tmdb.trending.trending(_:withinLast:completion:)
        let _: (String, String?, @escaping TMDBResult<ListDetails>) -> Void = tmdb.lists.details(for:language:completion:)
        let _: (Int, String, @escaping TMDBResult<ListItemStatus>) -> Void = tmdb.lists.itemStatus(itemId:listId:completion:)
    }

    func testOriginalFunctionValuesForwardToCanonicalRequests() throws {
        let movieChanges = tmdb.movies.changes(for:completion:)
        let tvImages = tmdb.tv.images(for:language:completion:)
        let listDetails = tmdb.lists.details(for:language:completion:)
        let application = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/movie/1/changes", application + [URLQueryItem(name: "page", value: "1")]) { movieChanges(1, $0) }
        try assertGETQuery("/3/tv/1/images", application + [URLQueryItem(name: "language", value: "fi-FI")]) { tvImages(1, "fi-FI", $0) }
        let authenticated = application + [URLQueryItem(name: "session_id", value: "456"), URLQueryItem(name: "language", value: "fi-FI")]
        try assertGETQuery("/3/list/1", authenticated) { listDetails("1", "fi-FI", $0) }
    }
}
