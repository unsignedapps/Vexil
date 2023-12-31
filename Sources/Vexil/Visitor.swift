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

public protocol FlagVisitor {

    func beginGroup(keyPath: FlagKeyPath)
    func endGroup(keyPath: FlagKeyPath)
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
