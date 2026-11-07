import XCTest
@testable import TMDBKit

final class SearchEndpointTests: TMDBTestCase {
    func testMovieSearchForwardsAllDocumentedOptions() throws {
        var requestCount = 0
        stubResponse(["page": 2, "results": [], "total_pages": 0, "total_results": 0]) { request in
            requestCount += 1
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/3/search/movie")
            let items = try self.queryItems(in: request)
            for (name, value) in [
                ("query", "Amélie & C++?/"),
                ("page", "2"),
                ("language", "fi-FI"),
                ("include_adult", "true"),
                ("region", "FI"),
                ("year", "2001"),
                ("primary_release_year", "2001"),
                ("api_key", "123")
            ] {
                XCTAssertEqual(items.filter { $0.name == name }.map { $0.value }, [value])
            }
            XCTAssertEqual(items.count, 8)
        }
        let response = try awaitFor {
            tmdb.search.searchForMovies("Amélie & C++?/", page: 2, language: "fi-FI", includeAdult: true,
                                        region: "FI", year: "2001", primaryReleaseYear: "2001", completion: $0)
        }.value
        XCTAssertEqual(response?.page, 2)
        XCTAssertEqual(response?.results.count, 0)
        XCTAssertEqual(requestCount, 1)
    }

    func testLegacyMovieSearchOmitsUnspecifiedOptions() throws {
        var requestCount = 0
        stubResponse(["page": 1, "results": [], "total_pages": 0, "total_results": 0]) { request in
            requestCount += 1
            XCTAssertEqual(request.url?.path, "/3/search/movie")
            let items = try self.queryItems(in: request)
            XCTAssertEqual(Set(items.map { $0.name }), Set(["query", "page", "api_key"]))
            XCTAssertEqual(items.count, 3)
            XCTAssertEqual(items.filter { $0.name == "query" }.map { $0.value }, ["Amélie"])
            XCTAssertEqual(items.filter { $0.name == "page" }.map { $0.value }, ["1"])
        }
        let response = try awaitFor { tmdb.search.searchForMovies("Amélie", page: 1, completion: $0) }.value
        XCTAssertEqual(response?.results.count, 0)
        XCTAssertEqual(response?.totalResults, 0)
        XCTAssertEqual(requestCount, 1)
    }

    func testMovieSearchPreservesFalseAndOmitsNilOptions() throws {
        stubResponse(["page": 1, "results": [], "total_pages": 0, "total_results": 0]) { request in
            let items = try self.queryItems(in: request)
            XCTAssertEqual(Set(items.map { $0.name }), Set(["query", "page", "api_key", "include_adult"]))
            XCTAssertEqual(items.filter { $0.name == "include_adult" }.map { $0.value }, ["false"])
        }
        XCTAssertNotNil(try awaitFor {
            tmdb.search.searchForMovies("Amélie", page: 1, language: nil, includeAdult: false,
                                        region: nil, year: nil, primaryReleaseYear: nil, completion: $0)
        }.value)
    }
}

extension SearchEndpointTests {
    func testSearchQueryEncodingRoundTripsSpecialCharacters() throws {
        stubResponse(["page": 2, "results": [], "total_pages": 7, "total_results": 121]) { request in
            try RequestExpectation(path: "/3/search/movie", query: ["api_key": "123", "query": "Amélie & C++?/", "page": "2", "language": "fi-FI", "include_adult": "false", "region": "FI", "year": "2001", "primary_release_year": "2001"]).assertRequest(request)
        }
        let response = try XCTUnwrap(awaitFor { tmdb.search.searchForMovies("Amélie & C++?/", page: 2, language: "fi-FI", includeAdult: false, region: "FI", year: "2001", primaryReleaseYear: "2001", completion: $0) }.value)
        XCTAssertEqual(response.page, 2)
        XCTAssertEqual(response.totalPages, 7)
        XCTAssertEqual(response.totalResults, 121)
        XCTAssertEqual(response.results.count, 0)
    }
}
