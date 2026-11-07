import XCTest
@testable import TMDBKit

final class NetworkCacheTests: TMDBTestCase {
    private var cache: TrackingURLCache!
    private var client: NetworkClient!
    private let state = Data(#"{"id":1,"favorite":false,"rated":false,"watchlist":false}"#.utf8)
    private let cachedState = Data(#"{"id":1,"favorite":true,"rated":false,"watchlist":false}"#.utf8)

    override func setUp() {
        super.setUp()
        cache = TrackingURLCache(memoryCapacity: 1024 * 1024, diskCapacity: 0, diskPath: nil)
        let config = URLSessionConfiguration.ephemeral
        // Only the injected manual cache participates; URLSession cannot hide a wire request.
        config.urlCache = nil
        config.protocolClasses = [MockURLProtocol.self]
        client = NetworkClient(authenticator: MockAuth(sessionId: "456"), urlSession: URLSession(configuration: config), cache: cache)
        tmdb = TMDB(authenticator: MockAuth(sessionId: "456"), networkClient: client)
    }

    override func tearDown() {
        super.tearDown()
        client = nil
        cache = nil
    }

    private func request(_ path: String = "/3/movie/1/account_states", method: String = "GET", session: String? = "456", apiKey: String = "123", body: Data? = nil) -> URLRequest {
        var components = URLComponents(string: "https://api.themoviedb.org" + path)!
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let session = session {
            components.queryItems!.append(URLQueryItem(name: "session_id", value: session))
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.httpBody = body
        if method != "GET" {
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        return request
    }

    private func headers(age: TimeInterval = 0, control: String = "max-age=3600", etag: String = "\"version-1\"") -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return ["Date": formatter.string(from: Date().addingTimeInterval(-age)), "Cache-Control": control, "ETag": etag]
    }

    private func seed(_ request: URLRequest, data: Data? = nil, headers: [String: String]) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: headers)!
        cache.storeCachedResponse(CachedURLResponse(response: response, data: data ?? cachedState), for: request)
        XCTAssertNotNil(cache.cachedResponse(for: request), "Seed must exist before testing cache policy")
    }

    private func respond(status: Int = 200, data: Data? = nil, headers: [String: String]? = nil, inspect: @escaping (URLRequest) -> Void) {
        MockURLProtocol.requestHandler = { request in
            inspect(request)
            return (HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!, data ?? self.state)
        }
    }

    func testFreshCacheAvoidsRequest() throws {
        seed(request(), headers: headers())
        var requests = 0
        respond { _ in requests += 1 }
        for _ in 0 ..< 2 {
            XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, true)
        }
        XCTAssertEqual(requests, 0)
    }

    func testExpiredCacheRevalidatesWithETag() throws {
        seed(request(), headers: headers(age: 3600, control: "max-age=1"))
        var requests = 0
        respond(headers: headers()) { request in
            requests += 1
            XCTAssertEqual(request.value(forHTTPHeaderField: "If-None-Match"), "\"version-1\"")
        }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertEqual(requests, 1)
        // A cacheable network replacement is subsequently fresh.
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertEqual(requests, 1)
    }

    func testNotModifiedReturnsCachedPayload() throws {
        seed(request(), headers: headers(age: 3600, control: "max-age=1"))
        var requests = 0
        respond(status: 304, data: Data(), headers: headers()) { request in
            requests += 1
            XCTAssertEqual(request.value(forHTTPHeaderField: "If-None-Match"), "\"version-1\"")
        }
        let result: Result<HTTPResponseContaining<AccountState>, TMDBError> = try awaitFor {
            tmdb.authenticatedRequestWithResponse(for: Movies.accountStates(movieId: 1), completion: $0)
        }
        XCTAssertEqual(result.value?.object.favorite, true)
        XCTAssertEqual(result.value?.responseStatusCode, 304)
        XCTAssertEqual(requests, 1)
    }

    func testNotModifiedWithoutCacheFails() throws {
        var requests = 0
        respond(status: 304, data: Data()) { request in
            requests += 1
            XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match"))
        }
        let result = try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }
        XCTAssertNil(result.value)
        guard case .httpError(304) = try underlyingError(XCTUnwrap(result.error)) as? TMDBError else { return XCTFail("Expected HTTP 304 failure") }
        XCTAssertEqual(requests, 1)
    }

    func testMutationsNeverReadOrPopulateCache() throws {
        for method in ["POST", "DELETE"] {
            cache.removeAllCachedResponses()
            let body = method == "POST" ? Data(#"{"value":8.5}"#.utf8) : nil
            let key = request("/3/movie/1/rating", method: method, body: body)
            // Foundation refuses mutation seeds. Observe actual cache access instead.
            XCTAssertNil(cache.cachedResponse(for: key))
            cache.resetCounts()
            var requests = 0
            respond(data: Data(#"{"status_code":1,"status_message":"wire"}"#.utf8), headers: headers()) { request in
                requests += 1
                XCTAssertEqual(request.httpMethod, method)
                XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match"))
                XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData)
                XCTAssertEqual(request.value(forHTTPHeaderField: "Cache-Control"), "no-store")
            }
            for _ in 0 ..< 2 {
                let result = try awaitFor { completion in
                    if method == "POST" {
                        tmdb.movies.rateMovie(1, rating: 8.5, completion: completion)
                    } else {
                        tmdb.movies.deleteRating(of: 1, completion: completion)
                    }
                }
                XCTAssertEqual(result.value?.statusMessage, "wire")
            }
            XCTAssertEqual(requests, 2)
            XCTAssertEqual(cache.reads, 0)
            XCTAssertEqual(cache.writes, 0)
            XCTAssertNil(cache.cachedResponse(for: key))
            cache.removeAllCachedResponses()
            _ = try awaitFor { completion in
                if method == "POST" {
                    tmdb.movies.rateMovie(1, rating: 8.5, completion: completion)
                } else {
                    tmdb.movies.deleteRating(of: 1, completion: completion)
                }
            }
            XCTAssertNil(cache.cachedResponse(for: key), "Never-cache response must not populate an empty cache")
        }
    }

    func testAuthenticationResponsesAreNotCached() throws {
        let token = RequestToken(success: true, expiresAt: "now", requestToken: "token")
        let operations: [(URLRequest, Data, (@escaping () -> Void) -> Void)] = [
            (request("/3/authentication/token/new", session: nil), Data(#"{"success":true,"expires_at":"now","request_token":"wire"}"#.utf8), { done in
                self.tmdb.createRequestToken { result in XCTAssertEqual(result.value?.requestToken, "wire")
                    done()
                }
            }),
            (request("/3/authentication/session/new", method: "POST", session: nil, body: Data(#"{"request_token":"token"}"#.utf8)), Data(#"{"success":true,"session_id":"wire"}"#.utf8), { done in
                self.tmdb.createSession(requestToken: token) { result in XCTAssertEqual(result.value?.sessionId, "wire")
                    done()
                }
            }),
            (request("/3/authentication/session", method: "DELETE", session: nil, body: Data(#"{"session_id":"456"}"#.utf8)), Data(#"{"success":true}"#.utf8), { done in
                self.tmdb.deleteSession { result in XCTAssertEqual(result.value?.success, true)
                    done()
                }
            })
        ]
        for (key, payload, invoke) in operations {
            cache.removeAllCachedResponses()
            let poison = Data("cached authentication response".utf8)
            if key.httpMethod == "GET" {
                seed(key, data: poison, headers: headers())
            }
            let prior = cache.cachedResponse(for: key)?.data
            cache.resetCounts()
            var requests = 0
            respond(data: payload, headers: headers()) { request in
                requests += 1
                XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match"))
                XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData)
                XCTAssertEqual(request.value(forHTTPHeaderField: "Cache-Control"), "no-store")
            }
            for _ in 0 ..< 2 {
                _ = try awaitFor { done in invoke { done(true) } }
            }
            XCTAssertEqual(requests, 2)
            XCTAssertEqual(cache.reads, 0)
            XCTAssertEqual(cache.writes, 0)
            XCTAssertEqual(cache.cachedResponse(for: key)?.data, prior)
            cache.removeAllCachedResponses()
            _ = try awaitFor { done in invoke { done(true) } }
            XCTAssertNil(cache.cachedResponse(for: key))
        }
    }

    func testNeverCacheNotModifiedCannotReuseStoredPayload() throws {
        let key = request("/3/authentication/token/new", session: nil)
        seed(key, data: Data(#"{"success":true,"expires_at":"now","request_token":"secret"}"#.utf8), headers: headers())
        var requests = 0
        respond(status: 304, data: Data()) { _ in requests += 1 }
        let result = try awaitFor { tmdb.createRequestToken(completion: $0) }
        XCTAssertNil(result.value)
        guard case .httpError(304) = try underlyingError(XCTUnwrap(result.error)) as? TMDBError else { return XCTFail("Never-cache must not return a stored token for 304") }
        XCTAssertEqual(requests, 1)
    }

    func testCredentialReplacementDoesNotReusePreviousAccountResponse() throws {
        struct Credentials: Authenticator { let apiKey: String
            let sessionId: String?
        }
        var requests = 0
        respond(headers: headers()) { request in
            requests += 1
            assertQuery(request, equals: requests == 1 ? ["api_key": "123", "session_id": "456"] : ["api_key": "new-key", "session_id": "new-session"])
        }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertNotNil(cache.cachedResponse(for: request()))
        tmdb.updateAuthenticator(Credentials(apiKey: "new-key", sessionId: "new-session"))
        respond(data: cachedState, headers: headers()) { request in
            requests += 1
            assertQuery(request, equals: ["api_key": "new-key", "session_id": "new-session"])
        }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, true)
        XCTAssertEqual(requests, 2)
    }

    func testClearCachesRemovesStoredResponses() throws {
        seed(request(), headers: headers())
        seed(request("/3/movie/2/account_states"), headers: headers())
        tmdb.clearCaches()
        XCTAssertNil(cache.cachedResponse(for: request()))
        XCTAssertNil(cache.cachedResponse(for: request("/3/movie/2/account_states")))
        var requests = 0
        respond { _ in requests += 1 }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertEqual(requests, 1)
    }

    func testResponseAgeHeaderAlsoExpiresCache() throws {
        var fields = headers(control: "max-age=60")
        fields["Age"] = "120"
        seed(request(), headers: fields)
        var requests = 0
        respond { _ in requests += 1 }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertEqual(requests, 1)
    }

    func testNoCacheAlwaysRevalidates() throws {
        seed(request(), headers: headers(control: "no-cache, max-age=3600"))
        var requests = 0
        respond { request in
            requests += 1
            XCTAssertEqual(request.value(forHTTPHeaderField: "If-None-Match"), "\"version-1\"")
        }
        XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        XCTAssertEqual(requests, 1)
    }

    func testNoStoreNeitherReadsNorStoresPayload() throws {
        seed(request(), headers: headers(control: "no-store, max-age=3600"))
        var requests = 0
        respond(headers: headers(control: "no-store, max-age=3600")) { request in
            requests += 1
            XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match"))
        }
        for _ in 0 ..< 2 {
            XCTAssertEqual(try awaitFor { tmdb.movies.accountStates(for: 1, completion: $0) }.value?.favorite, false)
        }
        XCTAssertEqual(requests, 2)
        XCTAssertNil(cache.cachedResponse(for: request()))
    }

    func testCacheHeaderNamesAreCaseInsensitive() {
        for fields in [["ETag": "quoted", "Cache-Control": "max-age=60"], ["etag": "quoted", "cache-control": "max-age=60"], ["ETAG": "quoted", "CACHE-CONTROL": "max-age=60"]] {
            let parsed = HTTPResponseHeaders(fields)
            XCTAssertEqual(parsed.etag, "quoted")
            XCTAssertEqual(parsed.maxAge, 60)
        }
    }
}

/// Observe access to a real memory-only Foundation cache, retaining its storage semantics.
private final class TrackingURLCache: URLCache {
    private let counterLock = NSLock()
    private var readCount = 0
    private var writeCount = 0

    var reads: Int {
        counterLock.lock()
        defer { counterLock.unlock() }
        return readCount
    }

    var writes: Int {
        counterLock.lock()
        defer { counterLock.unlock() }
        return writeCount
    }

    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        counterLock.lock()
        readCount += 1
        counterLock.unlock()
        return super.cachedResponse(for: request)
    }

    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        counterLock.lock()
        writeCount += 1
        counterLock.unlock()
        super.storeCachedResponse(cachedResponse, for: request)
    }

    func resetCounts() {
        counterLock.lock()
        readCount = 0
        writeCount = 0
        counterLock.unlock()
    }
}

#if compiler(>=5.5)
    /// Foundation protects storage; counterLock protects the added observation state.
    extension TrackingURLCache: @unchecked Sendable {}
#endif
