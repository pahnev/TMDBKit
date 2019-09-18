//
//  HTTPLogger.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

/**
 Class which prints log entries to the console about HTTP requests.
 Logging is disabled by default, and doesn't have any measurable runtime performance impact.
 It can be enabled by setting `HTTP_LOGGING` env variable
 */
final class HTTPLogger {
    typealias RequestIdentifier = Int

    private let internalQueue: DispatchQueue

    // These two values must be modified only from internalQueue
    private var requestStartDates: [RequestIdentifier: Date]
    private var lastIdentifier: RequestIdentifier

    init() {
        internalQueue = DispatchQueue(label: "HTTPLogger")
        lastIdentifier = 0
        requestStartDates = [:]
    }

    private func isLoggingEnabled() -> Bool {
        return true
    }

    func logStart(_ request: URLRequest) -> RequestIdentifier {
        guard isLoggingEnabled() else { return 0 }

        internalQueue.sync {
            lastIdentifier += 1
            requestStartDates[lastIdentifier] = Date()
        }

        print("HTTP -> \(request.httpMethod ?? ""): \(request.url?.description ?? "")")

        return lastIdentifier
    }

    func logComplete(with requestIdentifier: RequestIdentifier, data: Data?, response: URLResponse?, error: Error?) {
        guard isLoggingEnabled() else { return }
        guard let httpResponse = response as? HTTPURLResponse else { return }
        var startDateMaybe: Date?

        internalQueue.sync {
            startDateMaybe = requestStartDates[requestIdentifier]
            requestStartDates.removeValue(forKey: requestIdentifier)
        }

        guard let startDate = startDateMaybe else { return }

        let contentLength = Int(httpResponse.allHeaderFields["Content-Length"] as? String ?? "0") ?? 0
        let contentLengthString = ByteCountFormatter.string(fromByteCount: Int64(contentLength), countStyle: .file)

        let dataSize = data?.count ?? 0
        let dataSizeString = ByteCountFormatter.string(fromByteCount: Int64(dataSize), countStyle: .file)

        let duration = Date().timeIntervalSince(startDate)
        let speedString = String(format: "%.2f KB/sec", Double(contentLength / 1024) / duration)
        let durationString = String(format: "%.2f sec", duration)

        print("HTTP <- \(httpResponse.statusCode): transferred: \(contentLengthString) (\(speedString)); uncompressed: \(dataSizeString); \(durationString); \(httpResponse.url?.description ?? "")")
    }
}
