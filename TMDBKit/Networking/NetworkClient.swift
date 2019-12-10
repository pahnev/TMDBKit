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

        init(_ value: Data, headers: HTTPResponseHeaders) {
            self.value = value
            self.headers = headers
        }
    }

    case success(SuccessValue)
    case error(Error)
}

final class NetworkClient {
    private let authenticator: Authenticator
    private let httpLogger: HTTPLogger
    private let urlSession: URLSession

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
        httpLogger = HTTPLogger()

        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: urlConfiguration)
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

                return completion(.success(NetworkResult.SuccessValue(data, headers: HTTPResponseHeaders(httpResponse.allHeaderFields))))
            }
        }

        task.resume()
    }
}
