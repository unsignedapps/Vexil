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

// extension Snapshot: Identifiable {}
//
// extension Snapshot: Equatable where RootGroup: Equatable {
//    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
//        lhs._rootGroup == rhs._rootGroup
//    }
// }
//
// extension Snapshot: Hashable where RootGroup: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(_rootGroup)
//    }
// }
//
// extension Snapshot: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        "Snapshot<\(String(describing: RootGroup.self)), \(values.count) overrides>("
//            + Mirror(reflecting: _rootGroup).children
//            .map { _, value -> String in
//                (value as? CustomDebugStringConvertible)?.debugDescription
//                    ?? (value as? CustomStringConvertible)?.description
//                    ?? String(describing: value)
//            }
//            .joined(separator: "; ")
//            + ")"
//    }
// }
