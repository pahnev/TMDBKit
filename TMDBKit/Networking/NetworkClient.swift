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
        urlConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: urlConfiguration)
    }

    func cacheDiskStorageSize() -> Int {
        return cache.currentDiskUsage
    }

    func clearCaches() {
        cache.removeAllCachedResponses()
    }

    func executeAuthenticatedRequest(for endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping (NetworkResult) -> Void) {
        startRequest(authenticatedRequest(endpoint, additionalHeaders: additionalHeaders), completion: completion)
    }

}

private extension NetworkClient {
    func authenticatedRequest(_ endpoint: Endpoint, additionalHeaders: [String: String]) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.url = request.url?.appendingQueryItem(URLQueryItem(name: "api_key", value: authenticator.apiKey))

        request.httpMethod = endpoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endpoint.requestHeaders
        additionalHeaders.forEach { key, value in request.addValue(value, forHTTPHeaderField: key) }

        if let httpBody = endpoint.httpBody {
            request.httpBody = httpBody
        }

        return request
    }

    func startRequest(_ request: URLRequest, completion: @escaping (NetworkResult) -> Void) {

        let reqId = httpLogger.logStart(request)

        if let cachedResponse = cache.cachedResponse(for: request), let httpResponse = cachedResponse.response as? HTTPURLResponse {
            return completion(.success(NetworkResult.SuccessValue(value: cachedResponse.data,
                                                                  headers: HTTPResponseHeaders(httpResponse.allHeaderFields),
                                                                  statusCode: httpResponse.statusCode)))
        }

        let task = urlSession.dataTask(with: request) { data, response, httpRequestError in
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
                    return completion(.error(TMDBError.httpError(httpResponse.statusCode)))
                }

                self.cache.storeCachedResponse(CachedURLResponse(response: httpResponse, data: data), for: request)
                return completion(.success(NetworkResult.SuccessValue(value: data,
                                                                      headers: HTTPResponseHeaders(httpResponse.allHeaderFields),
                                                                      statusCode: httpResponse.statusCode)))
            }
        }

        task.resume()
    }
}
