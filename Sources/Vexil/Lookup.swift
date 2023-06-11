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

public protocol FlagLookup: AnyObject {

    @inlinable
    func lookup<Value>(key: String, in source: FlagValueSource?) -> (value: Value, source: String?)? where Value: FlagValue

#if !os(Linux)
//    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue
#endif
}

extension FlagPole: FlagLookup {

    /// This is the primary lookup function in a `FlagPole`. When you access the `Flag.wrappedValue`
    /// this lookup function is called.
    ///
    /// It iterates through our `FlagValueSource`s and asks each if they have a `FlagValue` for
    /// that key, returning the first non-nil value it finds.
    ///
    @inlinable
    public func lookup<Value>(key: String, in source: FlagValueSource?) -> (value: Value, source: String?)? where Value: FlagValue {
        if let source {
            return source.flagValue(key: key)
                .map { ($0, source.name) }
        }

        for source in _sources {
            if let value: Value = source.flagValue(key: key) {
                return (value, source.name)
            }
        }
        return nil
    }

#if !os(Linux)

    /// Retrieves a publsiher from the FlagPole that is bound to updates of a specific key
    ///
//    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue {
//        publisher
//            .compactMap { $0.flagValue(key: key) }
//            .eraseToAnyPublisher()
//    }

#endif
}
