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

// #if !os(Linux)
// import Combine
// #endif

extension Snapshot: FlagLookup {

    public func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue {
        values.withLock {
            $0[keyPath.key] as? Value
        }
    }

    public var changes: FlagChangeStream {
        stream.stream
    }

}
