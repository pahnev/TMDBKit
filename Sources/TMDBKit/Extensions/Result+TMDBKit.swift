//
//  Result+TMDBKit.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 01/08/2018.
//

import Foundation

public extension Result {
    /// Return the underlying Value object.
    var value: Success? {
        if case let .success(value) = self {
            return value
        }

        return nil
    }

    /// Returns the underlying Error object.
    var error: Failure? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }
}
