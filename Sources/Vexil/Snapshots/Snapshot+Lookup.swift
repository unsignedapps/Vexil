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

// #if !os(Linux)
// import Combine
// #endif

extension Snapshot: FlagLookup {

    public func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue {
        values[keyPath.key]?.value as? Value
    }

    public func locate<Value>(keyPath: FlagKeyPath, of valueType: Value.Type) -> (value: Value, sourceName: String)? where Value: FlagValue {
        guard let value = values[keyPath.key]?.value as? Value else {
            return nil
        }
        return (value, name)
    }

    public var changeStream: EmptyFlagChangeStream {
        .init()
    }

}
