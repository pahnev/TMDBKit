//
//  TMDB.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 29/06/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

public typealias TMDBResult<CachedObjectType> = (Result<CachedObjectType, TMDBError>) -> Void

public struct HTTPResponseContaining<Object: CodableEquatable>: CodableEquatable {
    /// The object received in the response.
    public let object: Object

    /// The HTTP status code of the response.
    public let responseStatusCode: Int
}

public struct RequestToken: CodableEquatable {
    public let success: Bool
    public let expiresAt: String
    public let requestToken: String
}

public struct Session: CodableEquatable {
    public let success: Bool
    public let sessionId: String
}

public struct SuccessResponse: CodableEquatable {
    public let success: Bool?
}

public struct StatusResponse: CodableEquatable {
    public let statusCode: Int
    public let statusMessage: String
}

public class TMDB {
    private var authenticator: Authenticator
    private let networkClient: NetworkClient

    public lazy var movies = MovieEndpoints(tmdb: self)
    public lazy var people = PeopleEndpoints(tmdb: self)
    public lazy var trending = TrendingEndpoints(tmdb: self)
    public lazy var tv = TVEndpoints(tmdb: self)
    public lazy var account = AccountEndpoints(tmdb: self)
    public lazy var lists = ListEndpoints(tmdb: self)

    public init(authenticator: Authenticator) throws {
        self.authenticator = authenticator
        networkClient = NetworkClient(authenticator: authenticator)
    }

    /// Updates the authentication details for the service. Can be called at
    /// - Parameter authenticator: The new `Authenticator` to use.
    public func updateAuthenticator(_ authenticator: Authenticator) {
        self.authenticator = authenticator
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
    public func createRequestToken(completion: @escaping TMDBResult<RequestToken>) {
        fetchObject(ofType: RequestToken.self, endpoint: Authentication.requestToken, completion: completion)
    }

    /// You can use this method to create a fully valid session ID once a user has validated the request token. More information about how this works can be found here: https://developers.themoviedb.org/3/authentication/how-do-i-generate-a-session-id.
    public func createSession(requestToken: RequestToken, completion: @escaping TMDBResult<Session>) {
        fetchObject(ofType: Session.self, endpoint: Authentication.createSession(requestToken: requestToken.requestToken), completion: completion)
    }

    /// If you would like to delete (or "logout") from a session, call this method with a valid `sessionId`.
    /// If you haven't initialized TMDB with `sessionId` this completes with `TMDBError.sessionIdMissing`
    /// - Parameter completion: The closure called when the deletion is finished.
    public func deleteSession(completion: @escaping TMDBResult<SuccessResponse>) {
        guard let sessionId = authenticator.sessionId else {
            completion(.failure(.sessionIdMissing))
            return
        }
        authenticatedRequestAndParse(Authentication.deleteSession(sessionId: sessionId), completion: completion)
    }

    /// Fetches the wanted object either from Cache if one is found, otherwise from the network. The successful network request is then cached.
    func fetchObject<CachedObjectType: CodableEquatable>(ofType: CachedObjectType.Type, endpoint: Endpoint, completion: @escaping TMDBResult<CachedObjectType>) {
        request(for: endpoint, additionalHeaders: [:], completion: { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                self.parse(ofType: CachedObjectType.self, value: value, completion: completion)
            }
        })
    }

    func request(for endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMDBResult<NetworkResult.SuccessValue>) {
        networkClient.executeRequest(for: endpoint, additionalHeaders: additionalHeaders) { result in
            switch result {
            case .error(let error):
                completion(.failure(TMDBError.networkError(error)))
            case .success(let value):
                completion(.success(value))
            }
        }
    }

    func authenticatedRequestWithResponse<Type: CodableEquatable>(for endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMDBResult<HTTPResponseContaining<Type>>) {
        networkClient.executeAuthenticatedRequest(for: endpoint,
                                                  sessionId: authenticator.sessionId,
                                                  additionalHeaders: additionalHeaders) { result in
            switch result {
            case .error(let error):
                completion(.failure(TMDBError.networkError(error)))
            case .success(let value):
                self.parseWithResponse(ofType: Type.self, value: value, completion: completion)
            }
        }
    }

    func authenticatedRequestAndParse<Type: CodableEquatable>(_ endpoint: Endpoint, additionalHeaders: [String: String] = [:], completion: @escaping TMDBResult<Type>) {
        networkClient.executeAuthenticatedRequest(for: endpoint,
                                                  sessionId: authenticator.sessionId,
                                                  additionalHeaders: additionalHeaders) { result in
            switch result {
            case .error(let error):
                completion(.failure(TMDBError.networkError(error)))
            case .success(let value):
                self.parse(ofType: Type.self, value: value, completion: completion)
            }
        }
    }
}

// MARK: - Private

private extension TMDB {
    func parseWithResponse<CachedObjectType>(ofType: CachedObjectType.Type, value: NetworkResult.SuccessValue, completion: TMDBResult<HTTPResponseContaining<CachedObjectType>>) where CachedObjectType: CodableEquatable {
        do {
            let object = try decodeObject(ofType: CachedObjectType.self, data: value.value)
            completion(.success(HTTPResponseContaining(object: object, responseStatusCode: value.statusCode)))
        } catch let error as TMDBError {
            completion(.failure(error))
        } catch {
            completion(.failure(TMDBError.unknownDecodingError(error)))
            preconditionFailure("There should be no other error thrown from parsing.")
        }
    }

    func parse<CachedObjectType>(ofType: CachedObjectType.Type, value: NetworkResult.SuccessValue, completion: TMDBResult<CachedObjectType>) where CachedObjectType: CodableEquatable {
        do {
            let object = try decodeObject(ofType: CachedObjectType.self, data: value.value)
            completion(.success(object))
        } catch let error as TMDBError {
            completion(.failure(error))
        } catch {
            completion(.failure(TMDBError.unknownDecodingError(error)))
            preconditionFailure("There should be no other error thrown from parsing.")
        }
    }

    func decodeObject<CachedObjectType>(ofType: CachedObjectType.Type, data: Data) throws -> CachedObjectType where CachedObjectType: Decodable {
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
}
