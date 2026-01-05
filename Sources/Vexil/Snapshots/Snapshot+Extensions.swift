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

extension Snapshot: Identifiable {}

extension Snapshot: Equatable where RootGroup: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        lhs.rootGroup == rhs.rootGroup
    }
}

extension Snapshot: Hashable where RootGroup: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rootGroup)
    }
}

extension Snapshot: CustomDebugStringConvertible {
    public var debugDescription: String {
        let describer = FlagDescriber()
        rootGroup.walk(visitor: describer)
        let count = values.withLock { $0.count }
        return "Snapshot<\(String(describing: RootGroup.self)), \(count) overrides>("
            + describer.descriptions.joined(separator: "; ")
            + ")"
    }
}
