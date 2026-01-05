//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

final class FlagSetter: FlagVisitor {

    let source: any FlagValueSource
    let keys: Set<String>
    var caughtError: (any Error)?

    init(source: any FlagValueSource, keys: Set<String>) {
        self.source = source
        self.keys = keys
    }

    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue {
        let key = keyPath.key
        guard keys.contains(key), caughtError == nil, let value = value() else {
            return
        }

        do {
            try source.setFlagValue(value, key: key)
        } catch {
            caughtError = error
        }
    }

    func apply(to container: some FlagContainer) throws {
        container.walk(visitor: self)
        if let caughtError {
            throw caughtError
        }
    }

}
