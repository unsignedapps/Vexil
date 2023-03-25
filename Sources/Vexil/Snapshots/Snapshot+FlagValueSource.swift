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

extension Snapshot: FlagValueSource {
    public var name: String {
        return displayName ?? "Snapshot \(id.uuidString)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return values[key]?.value as? Value
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        set(value, key: key)
    }
}
