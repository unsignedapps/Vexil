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

extension Snapshot: FlagValueSource {

    public var name: String {
        displayName ?? "Snapshot \(id)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        values[key] as? Value
    }

    public func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        set(value, key: key)
    }

}
