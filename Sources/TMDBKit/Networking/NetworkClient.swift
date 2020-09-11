//
//  NetworkClient.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum NetworkResult {
    struct SuccessValue {
        let value: Data
        let headers: HTTPResponseHeaders
        let statusCode: Int
    }

    case success(SuccessValue)
    case error(Error)
}

final class NetworkClient {
    private let authenticator: Authenticator
    private let httpLogger: HTTPLogger
    private let urlSession: URLSession
    private let cache: URLCache

    init(authenticator: Authenticator, cache: URLCache = URLCache.shared) {
        self.authenticator = authenticator
        self.cache = cache
        httpLogger = HTTPLogger()

        cache.diskCapacity = 100 * 1024 * 1024
        cache.memoryCapacity = 100 * 1024 * 1024

        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.requestCachePolicy = .useProtocolCachePolicy
        urlSession = URLSession(configuration: urlConfiguration)
    }

    func cacheDiskStorageSize() -> Int {
        return cache.currentDiskUsage
    }

    func clearCaches() {
        cache.removeAllCachedResponses()
    }

    func executeAuthenticatedRequest(for endpoint: Endpoint, sessionId: String?, additionalHeaders: [String: String] = [:], completion: @escaping (NetworkResult) -> Void) {
        guard let sessionId = sessionId else {
            completion(.error(TMDBError.sessionIdMissing))
            return
        }
        startRequest(authenticatedRequest(endpoint, sessionId: sessionId, additionalHeaders: additionalHeaders),
                     cachePolicy: endpoint.cachePolicy,
                     completion: completion)
    }

    func executeRequest(for endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping (NetworkResult) -> Void) {
        startRequest(authenticatedRequest(endpoint, additionalHeaders: additionalHeaders),
                     cachePolicy: endpoint.cachePolicy,
                     completion: completion)
    }

}

private extension NetworkClient {
    func urlFor(_ endpoint: Endpoint, sessionId: String?) -> URL {
        let url = endpoint.url.appendingQueryItem(URLQueryItem(name: "api_key", value: authenticator.apiKey))
        guard let sessionId = sessionId else { return url }
        return url.appendingQueryItem(URLQueryItem(name: "session_id", value: sessionId))
    }

    func authenticatedRequest(_ endpoint: Endpoint, sessionId: String? = nil, additionalHeaders: [String: String]) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.url = urlFor(endpoint, sessionId: sessionId)

        request.httpMethod = endpoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endpoint.requestHeaders
        additionalHeaders.forEach { key, value in request.addValue(value, forHTTPHeaderField: key) }

        if let httpBody = endpoint.httpBody {
            request.httpBody = httpBody
        }

        return request
    }

    func startRequest(_ request: URLRequest, cachePolicy: CachePolicy, completion: @escaping (NetworkResult) -> Void) {
        var modifiedRequest = request
        let reqId = httpLogger.logStart(request)
        let cachedResponse = cache.cachedResponse(for: request)

        if cachePolicy == .allowed,
           let cachedResponse = cachedResponse,
           let httpResponse = cachedResponse.response as? HTTPURLResponse {

            let headers = HTTPResponseHeaders(httpResponse.allHeaderFields)
            let now = Date()

            if let maxAge = headers.maxAge, maxAge > 0, now < Date.withTimeIntervalSinceNow(maxAge) ?? now {
                return completion(.success(NetworkResult.SuccessValue(value: cachedResponse.data,
                                                                      headers: headers,
                                                                      statusCode: httpResponse.statusCode)))
            }
            if let etag = headers.etag {
                modifiedRequest.addValue(etag, forHTTPHeaderField: "If-None-Match")
            }
        }

        let task = urlSession.dataTask(with: modifiedRequest) { data, response, httpRequestError in
            self.httpLogger.logComplete(with: reqId, data: data, response: response, error: httpRequestError)

            DispatchQueue.main.async {

                if let httpRequestError = httpRequestError {
                    return completion(.error(TMDBError.networkError(httpRequestError)))
                }

                guard let data = data else {
                    return completion(.error(TMDBError.emptyDataReceivedError))
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.error(TMDBError.nonHttpResponseError))
                }

                guard 200 ..< 300 ~= httpResponse.statusCode else {
                    // HTTP 304, Not modified, our cached response is valid, use it.
                    if httpResponse.statusCode == 304, let cachedResponse = cachedResponse {
                        return completion(.success(NetworkResult.SuccessValue(value: cachedResponse.data,
                                                                              headers: HTTPResponseHeaders(httpResponse.allHeaderFields),
                                                                              statusCode: httpResponse.statusCode)))

                    }
                    return completion(.error(TMDBError.httpError(httpResponse.statusCode)))
                }

                if cachePolicy == .allowed {
                    self.cache.storeCachedResponse(CachedURLResponse(response: httpResponse, data: data), for: modifiedRequest)
                }

                return completion(.success(NetworkResult.SuccessValue(value: data,
                                                                      headers: HTTPResponseHeaders(httpResponse.allHeaderFields),
                                                                      statusCode: httpResponse.statusCode)))
            }
        }

        task.resume()
    }
}

private extension Date {
    static func withTimeIntervalSinceNow(_ timeInterval: TimeInterval?) -> Date? {
        guard let timeInterval = timeInterval else { return nil }
        return Date().addingTimeInterval(timeInterval)
    }
}
