//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

final class FlagRemover: FlagVisitor {

    let source: any FlagValueSource
    var caughtError: (any Error)?

    init(source: any FlagValueSource) {
        self.source = source
    }

    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue {
        guard caughtError == nil else {
            return
        }

        do {
            try source.setFlagValue(Value?.none, key: keyPath.key)
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
