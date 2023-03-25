//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if !os(Linux)
import Combine
#endif

import Foundation

/// An internal protocol that is provided to each `Flag` when it is decorated.
/// The `Flag.wrappedValue` then uses this protocol to lookup what the current
/// value of a flag is from the source hierarchy.
///
/// Only `FlagPole` and `Snapshot`s conform to this.
///
internal protocol Lookup: AnyObject {
    func lookup<Value>(key: String, in source: FlagValueSource?) -> LookupResult<Value>? where Value: FlagValue

#if !os(Linux)
    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue
#endif
}

/// A lightweight internal type used to support diagnostics by tagging the values with the source that resolved it
struct LookupResult<Value> where Value: FlagValue {
    let source: String?
    let value: Value
}

extension FlagPole: Lookup {

    /// This is the primary lookup function in a `FlagPole`. When you access the `Flag.wrappedValue`
    /// this lookup function is called.
    ///
    /// It iterates through our `FlagValueSource`s and asks each if they have a `FlagValue` for
    /// that key, returning the first non-nil value it finds.
    ///
    func lookup<Value>(key: String, in source: FlagValueSource?) -> LookupResult<Value>? where Value: FlagValue {
        if let source = source {
            return source.flagValue(key: key)
                .map { LookupResult(source: source.name, value: $0) }
        }

        for source in _sources {
            if let value: Value = source.flagValue(key: key) {
                return LookupResult(source: source.name, value: value)
            }
        }
        return nil
    }

#if !os(Linux)

    /// Retrieves a publsiher from the FlagPole that is bound to updates of a specific key
    ///
    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue {
        publisher
            .compactMap { $0.flagValue(key: key) }
            .eraseToAnyPublisher()
    }

#endif
}
