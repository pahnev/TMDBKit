//
//  TMDB.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public typealias TMBDResult<CachedObjectType> = (Result<CachedObjectType, TMDBError>) -> Void

public struct RequestToken: CodableEquatable {
    public let success: Bool
    public let expiresAt: String
    public let requestToken: String
}

public struct Session: CodableEquatable {
    public let success: Bool
    public let sessionId: String
}

public struct StatusResponse: CodableEquatable {
    public let statusCode: Int
    public let statusMessage: String
}

public protocol SessionProvider {
    var sessionId: String { get }
}

public class TMDB {
    private let authenticator: Authenticator
    private let networkClient: NetworkClient
    var sessionProvider: SessionProvider?
    public lazy var people = TMDB.PeopleEndpoints(tmdb: self)

    public init(authenticator: Authenticator) throws {
        self.authenticator = authenticator
        networkClient = NetworkClient(authenticator: authenticator)
    }

    public func setSessionProvider(_ sessionProvider: SessionProvider) {
        self.sessionProvider = sessionProvider
    }

    /// - Returns: Total byte size of all caches stored on disk by TMDBKit
    public func cacheDiskStorageSize() -> Int {
        return networkClient.cacheDiskStorageSize()
    }

    /// Removes all cached data from memory and disk.
    public func clearCaches() {
        networkClient.clearCaches()
    }

    /// Create a temporary request token that can be used to validate a TMDb user login. More details about how this works can be found here: https://developers.themoviedb.org/3/authentication/how-do-i-generate-a-session-id.
    public func createRequestToken(completion: @escaping TMBDResult<RequestToken>) {
        authenticatedRequestAndParse(Authentication.requestToken, completion: completion)
    }

    /// You can use this method to create a fully valid session ID once a user has validated the request token. More information about how this works can be found here: https://developers.themoviedb.org/3/authentication/how-do-i-generate-a-session-id.
    public func createSession(requestToken: RequestToken, completion: @escaping TMBDResult<Session>) {
        authenticatedRequestAndParse(Authentication.createSession(requestToken: requestToken.requestToken), completion: completion)
    }


    /// Fetches the wanted object either from Cache if one is found, otherwise from the network. The successfull network request is then cached.
    ///
    /// - Parameters:
    ///   - ofType: The object that should be fetched. Has to conform to CodableEquatable.
    ///   - cacheConfig: The Cache configuration defining where to look for the object or cache in case it has to be fetched from network.
    ///   - endpoint: The API endpoint to fetch the object from.
    ///   - completion: The closure called when the fetch is finished. Returns either the object requested or TMDBError if something failed.
    func fetchObject<CachedObjectType: CodableEquatable>(ofType: CachedObjectType.Type, endpoint: Endpoint, completion: @escaping TMBDResult<CachedObjectType>) {
        fetchObjectFromNetwork(ofType: CachedObjectType.self, endpoint: endpoint, completion: completion)
    }

    /// Performs authenticated request and returns either NetworkResult.SuccessValue on successful completion or TMDBError if something failed.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to make the request to.
    ///   - additionalHeaders: Any additional header values that should be added to the request.
    ///   - completion: The closure called when the fetch is finished. Returns either NetworkResult.SuccessValue on successful completion or TMDBError if something failed.
    func authenticatedRequest(for endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMBDResult<NetworkResult.SuccessValue>) {
        networkClient.executeAuthenticatedRequest(for: endpoint, additionalHeaders: additionalHeaders) { result in
            switch result {
            case .error(let error):
                completion(.failure(TMDBError.networkError(error)))
            case .success(let value):
                completion(.success(value))
            }
        }
    }

    func authenticatedRequestAndParse<Type: CodableEquatable>(_ endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMBDResult<Type>) {
        networkClient.executeAuthenticatedRequest(for: endpoint, additionalHeaders: additionalHeaders) { result in
            switch result {
            case .error(let error):
                completion(.failure(TMDBError.networkError(error)))
            case .success(let value):
                do {
                    let parsedObject = try self.parseObject(ofType: Type.self, data: value.value)
                    completion(.success(parsedObject))
                } catch let error as TMDBError {
                    return completion(.failure(error))
                } catch {
                    preconditionFailure("There should no other error thrown from parsing.")
                }
            }
        }
    }

}

// MARK: - Private

private extension TMDB {

    func parseObject<CachedObjectType>(ofType: CachedObjectType.Type, data: Data) throws -> CachedObjectType where CachedObjectType: Decodable {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(CachedObjectType.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            print("JSON parsing failed, data is corrupted. Context: \(context)")
            throw TMDBError.decodingError(DecodingError.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let codingKey, let context) {
            print("JSON parsing failed, key not found. CodingKey: '\(codingKey)'. Context: \(context)")
            throw TMDBError.decodingError(DecodingError.keyNotFound(codingKey, context))
        } catch DecodingError.typeMismatch(let object, let context) {
            print("JSON parsing failed, type mismatch. Object: \(object). Context: \(context)")
            throw TMDBError.decodingError(DecodingError.typeMismatch(object, context))
        } catch DecodingError.valueNotFound(let object, let context) {
            print("JSON parsing failed, value not found. Object: \(object). Context: \(context)")
            throw TMDBError.decodingError(DecodingError.valueNotFound(object, context))
        }
    }

    func parseAndCache<CachedObjectType>(ofType: CachedObjectType.Type, value: NetworkResult.SuccessValue, completion: TMBDResult<CachedObjectType>) where CachedObjectType: CodableEquatable {
        let parsedObject: CachedObjectType
        do {
            parsedObject = try self.parseObject(ofType: CachedObjectType.self, data: value.value)
            completion(.success(parsedObject))
        } catch let error as TMDBError {
            return completion(.failure(error))
        } catch {
            preconditionFailure("There should no other error thrown from parsing.")
        }
    }

    func fetchObjectFromNetwork<CachedObjectType: CodableEquatable>(ofType: CachedObjectType.Type, endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMBDResult<CachedObjectType>) {

        authenticatedRequest(for: endpoint, additionalHeaders: additionalHeaders, completion: { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                self.parseAndCache(ofType: CachedObjectType.self, value: value, completion: completion)
            }
        })
    }

}
