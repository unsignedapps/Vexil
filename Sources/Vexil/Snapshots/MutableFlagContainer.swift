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

import Foundation

/// A `MutableFlagGroup` is a wrapper type that provides a "setter" for each contained `Flag`.
@dynamicMemberLookup
public class MutableFlagContainer<Container> where Container: FlagContainer {


    // MARK: - Properties

    private let container: Container
    private let source: any FlagValueSource


    // MARK: - Dynamic Member Lookup

    /// A @dynamicMemberLookup implementation for subgroups
    ///
    /// Returns a `MutableFlagGroup` for the Subgroup at the specified KeyPath.
    ///
    /// ```swift
    /// flagPole.mySubgroup.mySecondSubgroup    // -> FlagGroup<MySecondSubgroup>
    /// snapshot.mySubgroup.mySecondSubgroup    // -> MutableFlagGroup<MySecondSubgroup>
    /// ```
    ///
    public subscript<C>(dynamicMember dynamicMember: KeyPath<Container, C>) -> MutableFlagContainer<C> where C: FlagContainer {
        let group = container[keyPath: dynamicMember]
        return MutableFlagContainer<C>(group: group, source: source)
    }

    /// A @dynamicMemberLookup implementation for FlagValues used solely to provide a `setter`.
    ///
    /// Takes a lock on the Snapshot to read and write values to it.
    ///
    /// ```swift
    /// flagPole.mySubgroup.myFlag = true       // Error: FlagPole is not mutable
    /// snapshot.mySubgroup.myFlag = true       // 👍
    /// ```
    ///
    public subscript<Value>(dynamicMember dynamicMember: KeyPath<Container, Value>) -> Value where Value: FlagValue {
        get {
            container[keyPath: dynamicMember]
        }
        set {
            if let keyPath = container._allFlagKeyPaths[dynamicMember] {
                // We know the source is a Snapshot, and snapshot.setFlagValue() does not throw
                try! source.setFlagValue(newValue, key: keyPath.key)
            }
        }
    }

    /// Internal initialiser used to create MutableFlagGroups for a given subgroup and snapshot
    init(group: Container, source: any FlagValueSource) {
        self.container = group
        self.source = source
    }

}


// MARK: - Equatable and Hashable Support

extension MutableFlagContainer: Equatable where Container: Equatable {
    public static func == (lhs: MutableFlagContainer, rhs: MutableFlagContainer) -> Bool {
        lhs.container == rhs.container
    }
}

extension MutableFlagContainer: Hashable where Container: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.container)
    }
}

// MARK: - Debugging

// extension MutableFlagContainer: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        "\(String(describing: Group.self))("
//        + Mirror(reflecting: group).children
//            .map { _, value -> String in
//                (value as? CustomDebugStringConvertible)?.debugDescription
//                ?? (value as? CustomStringConvertible)?.description
//                ?? String(describing: value)
//            }
//            .joined(separator: ", ")
//        + ")"
//    }
// }
