//
//  Result.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

public enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)

    /// Constructs a success wrapping a `value`.
    public init(value: Value) {
        self = .success(value)
    }

    /// Constructs a failure wrapping an `error`.
    public init(error: Error) {
        self = .failure(error)
    }

    /// Return the underlying Value object.
    public var value: Value? {
        if case let .success(value) = self {
            return value
        }

        return nil
    }

    /// Returns the underlying Error objcet
    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }

}
