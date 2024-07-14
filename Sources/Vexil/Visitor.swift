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

/// Vexil provides the ability to walk its flag hierarchy using the
/// Visitor pattern. Conform your type to this protocol and pass
/// it to ``FlagPole/walk(visitor:)`` or any container using
/// ``FlagContainer/walk(visitor:)``.
public protocol FlagVisitor {

    /// Called when beginning to visit a new ``FlagGroup``
    func beginGroup(keyPath: FlagKeyPath)

    /// Called when finished visiting a ``FlagGroup``
    func endGroup(keyPath: FlagKeyPath)

    /// Called when visiting a flag. Provided parameters include closures you can
    /// use to grab the current or real-time flag values.
    ///
    /// - Parameters:
    ///   - keyPath:        The ``FlagKeyPath`` where the flag is found at.
    ///   - value:          A closure you can use to obtain the current flag value.
    ///   - defaultValue:   The hardcoded default value of the flag if it is not overridden by ``FlagValueSource``s.
    ///   - wigwag:         A closure you can use to obtain the flag's WigWag. You can obtain additional information
    ///                     about the flag or subscribe to real-time flag value changes via the WigWag.
    ///
    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue

}

// MARK: - Defaults

// By default most visitors only care about flags so we provide
// default empty implementations so they don't have to.

public extension FlagVisitor {

    func beginGroup(keyPath: FlagKeyPath) {
        // Intentionally left blank
    }

    func endGroup(keyPath: FlagKeyPath) {
        // Intentionally left blank
    }

}
