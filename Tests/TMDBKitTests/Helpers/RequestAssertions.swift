import Foundation
import XCTest

func assertQuery(_ request: URLRequest, equals expected: [String: String],
                 file: StaticString = #file, line: UInt = #line) {
    let items = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
    let groups = Dictionary(grouping: items, by: { $0.name })
    for (key, values) in groups {
        XCTAssertEqual(values.count, 1, "Duplicate query key: \(key)", file: file, line: line)
    }
    for item in items { XCTAssertNotNil(item.value, "Missing query value: \(item.name)", file: file, line: line) }
    // Do not use uniqueKeysWithValues: duplicates must produce an assertion, not a trap.
    let actual = groups.mapValues { $0.first?.value ?? "" }
    XCTAssertEqual(actual, expected, file: file, line: line)
}

func requestBodyData(_ request: URLRequest) throws -> Data {
    if let body = request.httpBody { return body }
    let stream = try XCTUnwrap(request.httpBodyStream)
    stream.open()
    defer { stream.close() }
    var body = Data()
    var buffer = [UInt8](repeating: 0, count: 1024)
    while stream.hasBytesAvailable {
        let count = stream.read(&buffer, maxLength: buffer.count)
        if count < 0 { throw try XCTUnwrap(stream.streamError) }
        if count == 0 { break }
        body.append(contentsOf: buffer.prefix(count))
    }
    return body
}

func requestBodyJSON(_ request: URLRequest) throws -> [String: Any] {
    try XCTUnwrap(JSONSerialization.jsonObject(with: requestBodyData(request)) as? [String: Any])
}

/// Expectations are supplied as contract literals by each test, independently of Endpoint.
struct RequestExpectation {
    let path: String
    var method = "GET"
    var query: [String: String] = ["api_key": "123"]
    var body: [String: Any]? = nil
    var contentType: String? = nil

    func assertRequest(_ request: URLRequest, file: StaticString = #file, line: UInt = #line) throws {
        XCTAssertEqual(request.url?.scheme, "https", file: file, line: line)
        XCTAssertEqual(request.url?.host, "api.themoviedb.org", file: file, line: line)
        XCTAssertEqual(request.url?.path, path, file: file, line: line)
        XCTAssertEqual(request.httpMethod, method, file: file, line: line)
        assertQuery(request, equals: query, file: file, line: line)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"), file: file, line: line)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), contentType, file: file, line: line)
        if let body = body {
            let actual = try JSONSerialization.data(withJSONObject: requestBodyJSON(request), options: .sortedKeys)
            let expected = try JSONSerialization.data(withJSONObject: body, options: .sortedKeys)
            XCTAssertEqual(String(data: actual, encoding: .utf8), String(data: expected, encoding: .utf8), file: file, line: line)
        } else {
            XCTAssertNil(request.httpBody, file: file, line: line)
            XCTAssertNil(request.httpBodyStream, file: file, line: line)
        }
    }
}
