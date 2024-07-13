//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
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
    func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue

    //    @inlinable
    //    func value<Value>(for keyPath: FlagKeyPath, in source: any FlagValueSource) -> Value? where Value: FlagValue

    var changeStream: FlagChangeStream { get }

}

extension FlagPole: FlagLookup {

    @inlinable
    public func value<Value>(for keyPath: FlagKeyPath, in source: any FlagValueSource) -> Value? where Value: FlagValue {
        source.flagValue(key: keyPath.key)
    }

    /// This is the primary lookup function in a `FlagPole`. When you access the `Flag.wrappedValue`
    /// this lookup function is called.
    ///
    /// It iterates through our `FlagValueSource`s and asks each if they have a `FlagValue` for
    /// that key, returning the first non-nil value it finds.
    ///
    @inlinable
    public func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue {
        for source in _sources {
            if let value: Value = source.flagValue(key: keyPath.key) {
                return value
            }
        }
        return nil
    }

}

