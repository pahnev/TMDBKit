//
//  ListEndpointTests.swift
//
//
//  Created by Kirill Pahnev on 12.10.2023.
//

import CoreFoundation
import XCTest
@testable import TMDBKit

class ListEndpointTests: TMDBTestCase {
    func testListReadsWorkWithoutUserSession() throws {
        tmdb = makeTMDB(authenticator: MockAuth(sessionId: nil))
        let app = [URLQueryItem(name: "api_key", value: "123")]
        try assertGETQuery("/3/list/1", app) { tmdb.lists.details(for: "1", completion: $0) }
        try assertGETQuery("/3/list/1/item_status", app + [URLQueryItem(name: "movie_id", value: "2")]) { tmdb.lists.itemStatus(itemId: 2, listId: "1", completion: $0) }
    }

    func testListReadOptions() throws {
        let authenticated = [URLQueryItem(name: "api_key", value: "123"), URLQueryItem(name: "session_id", value: "456")]
        try assertGETQuery("/3/list/1", authenticated) { tmdb.lists.details(for: "1", completion: $0) }
        try assertGETQuery("/3/list/1", authenticated) { tmdb.lists.details(for: "1", pageNumber: nil, completion: $0) }
        try assertGETQuery("/3/list/1", authenticated + [URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.lists.details(for: "1", language: "fi-FI", pageNumber: 2, completion: $0)
        }
        let item = authenticated + [URLQueryItem(name: "movie_id", value: "2")]
        try assertGETQuery("/3/list/1/item_status", item) { tmdb.lists.itemStatus(itemId: 2, listId: "1", completion: $0) }
        try assertGETQuery("/3/list/1/item_status", item) { tmdb.lists.itemStatus(itemId: 2, listId: "1", language: nil, completion: $0) }
        try assertGETQuery("/3/list/1/item_status", item + [URLQueryItem(name: "language", value: "fi-FI")]) {
            tmdb.lists.itemStatus(itemId: 2, listId: "1", language: "fi-FI", completion: $0)
        }
    }

    func test_details() throws {
        try stubHelper.stubWithLocalFile(Lists.details(listId: "1", language: nil), expecting: .init(path: "/3/list/1", query: ["api_key": "123", "session_id": "456"]))

        let list = try XCTUnwrap(awaitFor { tmdb.lists.details(for: "1", completion: $0) }.value)

        XCTAssertEqual(list.id, "50941077760ee35e1500000c")
        XCTAssertEqual(list.name, "The Marvel Universe")
        XCTAssertEqual(list.description, "The idea behind this list is to collect the live action comic book movies from within the Marvel franchise. Last updated on Dec 18, 2013.")
        XCTAssertEqual(list.favoriteCount, 0)
        XCTAssertEqual(list.itemCount, 49)
        XCTAssertEqual(list.items.count, 49)
        XCTAssertEqual(list.iso6391, "en")
        XCTAssertNil(list.listType)
        XCTAssertEqual(list.posterPath, "/coJVIUEOToAEGViuhclM7pXC75R.jpg")
        XCTAssertEqual(list.id, "50941077760ee35e1500000c")
        XCTAssertEqual(list.name, "The Marvel Universe")
    }

    func test_itemStatus() throws {
        try stubHelper.stubWithLocalFile(Lists.itemStatus(listId: "1", movieId: 1), expecting: .init(path: "/3/list/1/item_status", query: ["api_key": "123", "session_id": "456", "movie_id": "1"]))
        let response = try XCTUnwrap(awaitFor { tmdb.lists.itemStatus(itemId: 1, listId: "1", completion: $0) }.value)
        XCTAssertEqual(response.id, "50941077760ee35e1500000c")
        XCTAssertFalse(response.itemPresent)
        XCTAssertEqual(response.id, "50941077760ee35e1500000c")
    }

    func test_createWith() throws {
        try stubHelper.stubWithLocalFile(Lists.createList(list: .init(name: "1", description: "1", language: "en")), expecting: .init(path: "/3/list", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["name": "Test", "description": "", "language": ""], contentType: "application/json;charset=utf-8"))
        let response = try XCTUnwrap(awaitFor { tmdb.lists.createWith(name: "Test", description: nil, language: nil, completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 1)
        XCTAssertEqual(response.listId, 5861)
        XCTAssertEqual(response.statusMessage, "The item/record was created successfully.")
        XCTAssertTrue(response.success)
    }

    func test_addMovie() throws {
        try stubHelper.stubWithLocalFile(Lists.addMovie(listId: "1", mediaId: 1), expecting: .init(path: "/3/list/1/add_item", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["media_id": 1], contentType: "application/json;charset=utf-8"))
        let response = try XCTUnwrap(awaitFor { tmdb.lists.addMovie(movieId: 1, to: "1", completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 12)
        XCTAssertEqual(response.statusMessage, "The item/record was updated successfully.")
    }

    func test_removeMovie() throws {
        try stubHelper.stubWithLocalFile(Lists.removeMovie(listId: "1", mediaId: 1), expecting: .init(path: "/3/list/1/remove_item", method: "POST", query: ["api_key": "123", "session_id": "456"], body: ["media_id": 1], contentType: "application/json;charset=utf-8"))
        let response = try XCTUnwrap(awaitFor { tmdb.lists.removeMovie(movieId: 1, from: "1", completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 12)
        XCTAssertEqual(response.statusMessage, "The item/record was updated successfully.")
    }

    func testClearListIncludesConfirmation() {
        let query = URLComponents(url: Lists.clearList(listId: "1").url, resolvingAgainstBaseURL: false)!.queryItems ?? []
        XCTAssertEqual(query.filter { $0.name == "confirm" }, [URLQueryItem(name: "confirm", value: "true")])
    }

    func test_clearList() throws {
        try stubHelper.stubWithLocalFile(Lists.clearList(listId: "1"), expecting: .init(path: "/3/list/1/clear", method: "POST", query: ["api_key": "123", "session_id": "456", "confirm": "true"], contentType: "application/json;charset=utf-8"))
        let response = try XCTUnwrap(awaitFor { tmdb.lists.clear(listId: "1", completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 12)
        XCTAssertEqual(response.statusMessage, "The item/record was updated successfully.")
    }

    func test_deleteList() throws {
        try stubHelper.stubEndpoint(Lists.deleteList(listId: "1"), expecting: .init(path: "/3/list/1", method: "DELETE", query: ["api_key": "123", "session_id": "456"]),
                                    with: [
                                        "status_code": 12,
                                        "status_message": "The item/record was updated successfully."
                                    ])
        let response = try XCTUnwrap(awaitFor { tmdb.lists.delete(listId: "1", completion: $0) }.value)
        XCTAssertEqual(response.statusCode, 12)
        XCTAssertEqual(response.statusMessage, "The item/record was updated successfully.")
    }

    func test_httpMethod() {
        XCTAssertEqual(Lists.details(listId: "1", language: nil).httpMethod, .GET)
        XCTAssertEqual(Lists.itemStatus(listId: "1", movieId: 1).httpMethod, .GET)
        XCTAssertEqual(Lists.createList(list: .init(name: "1", description: "1", language: "en")).httpMethod, .POST)
        XCTAssertEqual(Lists.addMovie(listId: "1", mediaId: 1).httpMethod, .POST)
        XCTAssertEqual(Lists.removeMovie(listId: "1", mediaId: 1).httpMethod, .POST)
        XCTAssertEqual(Lists.clearList(listId: "1").httpMethod, .POST)
        XCTAssertEqual(Lists.deleteList(listId: "1").httpMethod, .DELETE)
    }

    func test_httpBody() {
        XCTAssertNil(Lists.details(listId: "1", language: nil).httpBody)
        XCTAssertNil(Lists.itemStatus(listId: "1", movieId: 1).httpBody)
        XCTAssertNotNil(Lists.createList(list: .init(name: "1", description: "1", language: "en")).httpBody)
        XCTAssertNotNil(Lists.addMovie(listId: "1", mediaId: 1).httpBody)
        XCTAssertNotNil(Lists.removeMovie(listId: "1", mediaId: 1).httpBody)
        XCTAssertNil(Lists.clearList(listId: "1").httpBody)
        XCTAssertNil(Lists.deleteList(listId: "1").httpBody)
    }

    func test_createListHTTPBody() throws {
        let list = Lists.List(name: "1", description: "1", language: "en")
        let body = try XCTUnwrap(Lists.createList(list: list).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["name", "description", "language"]))
        XCTAssertEqual(object["name"] as? String, "1")
        XCTAssertEqual(object["description"] as? String, "1")
        XCTAssertEqual(object["language"] as? String, "en")
    }

    func test_addMovie_HTTPBody() throws {
        let body = try XCTUnwrap(Lists.addMovie(listId: "1", mediaId: 1).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["media_id"]))
        let number = try XCTUnwrap(object["media_id"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
        XCTAssertEqual(number.doubleValue, 1)
    }

    func test_removeMovie_HTTPBody() throws {
        let body = try XCTUnwrap(Lists.removeMovie(listId: "1", mediaId: 1).httpBody)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["media_id"]))
        let number = try XCTUnwrap(object["media_id"] as? NSNumber)
        XCTAssertEqual(CFGetTypeID(number), CFNumberGetTypeID())
        XCTAssertEqual(number.doubleValue, 1)
    }

    func test_requestHeaders() {
        let expectedHeaders = ["Content-Type": "application/json;charset=utf-8"]
        XCTAssertEqual(Lists.details(listId: "1", language: nil).requestHeaders, [:])
        XCTAssertEqual(Lists.itemStatus(listId: "1", movieId: 1).requestHeaders, [:])
        XCTAssertEqual(Lists.deleteList(listId: "1").requestHeaders, [:])

        XCTAssertEqual(Lists.createList(list: .init(name: "1", description: "1", language: "en")).requestHeaders, expectedHeaders)
        XCTAssertEqual(Lists.addMovie(listId: "1", mediaId: 1).requestHeaders, expectedHeaders)
        XCTAssertEqual(Lists.removeMovie(listId: "1", mediaId: 1).requestHeaders, expectedHeaders)
        XCTAssertEqual(Lists.clearList(listId: "1").requestHeaders, expectedHeaders)
    }

    func test_urlConstruction() {
        XCTAssertEqual(Lists.details(listId: "1", language: nil).url, URL(string: "https://api.themoviedb.org/3/list/1"))
        XCTAssertEqual(Lists.details(listId: "1", language: "en").url, URL(string: "https://api.themoviedb.org/3/list/1?language=en"))
        XCTAssertEqual(Lists.itemStatus(listId: "1", movieId: 1).url, URL(string: "https://api.themoviedb.org/3/list/1/item_status?movie_id=1"))
        XCTAssertEqual(Lists.createList(list: .init(name: "1", description: "1", language: "en")).url, URL(string: "https://api.themoviedb.org/3/list"))
        XCTAssertEqual(Lists.addMovie(listId: "1", mediaId: 1).url, URL(string: "https://api.themoviedb.org/3/list/1/add_item"))
        XCTAssertEqual(Lists.removeMovie(listId: "1", mediaId: 1).url, URL(string: "https://api.themoviedb.org/3/list/1/remove_item"))
        XCTAssertEqual(Lists.clearList(listId: "1").url, URL(string: "https://api.themoviedb.org/3/list/1/clear?confirm=true"))
        XCTAssertEqual(Lists.deleteList(listId: "1").url, URL(string: "https://api.themoviedb.org/3/list/1"))
    }
}
