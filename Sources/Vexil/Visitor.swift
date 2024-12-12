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

/// Vexil provides the ability to walk its flag hierarchy using the
/// Visitor pattern. Conform your type to this protocol and pass
/// it to ``FlagPole/walk(visitor:)`` or any container using
/// ``FlagContainer/walk(visitor:)``.
///
/// Walking always starts at a Container, and then walks the children of that container.
/// When one of the children is a group, a call to ``beginGroup(keyPath:wigwag:)`` is made before
/// descending into the group's container. That container will then call ``beginContainer(keyPath:container:)``
/// itself. You can use this to differentiate between the operations you are looking for.
///
/// # Example
///
/// Given the following flag hierarchy:
///
/// ```swift
/// @FlagContainer
/// struct TestFlags {
///
///     @Flag(...)
///     var topLevelFlag: Bool
///
///     @FlagGroup(...)
///     var subgroup: SubgroupFlags
///
/// }
///
/// @FlagContainer
/// struct SubgroupFlags {
///
///     @FlagGroup(...)
///     var doubleSubgroup: DoubleSubgroupFlags
///
/// }
///
/// @FlagContainer
/// struct DoubleSubgroupFlags {
///
///     @Flag(...)
///     var thirdLevelFlag: Bool
///
/// }
/// ```
///
/// You should expect to see the following callbacks:
///
/// ```swift
/// visitor.beginContainer("") // root
/// visitor.visitFlag("top-level-flag")
/// visitor.beginGroup("subgroup")
///
/// visitor.beginContainer("subgroup")
/// visitor.beginGroup("subgroup.double-subgroup")
///
/// visitor.beginContainer("subgroup.double-subgroup")
/// visitor.visitFlag("subgroup.double-subgroup.third-level-flag")
/// visitor.endContainer("subgroup.double-subgroup")
///
/// visitor.endGroup("subgroup.double-subgroup")
/// visitor.endContainer("subgroup")
///
/// visitor.endGroup("subgroup")
/// visitor.endContainer("") // root
/// ```
///
public protocol FlagVisitor {

    /// Called when beginning to walk within a ``FlagContainer``
    func beginContainer<Container>(keyPath: FlagKeyPath, containerType: Container.Type)

    /// Called when finished visiting a ``FlagContainer``.
    func endContainer(keyPath: FlagKeyPath)

    /// Called when about to descend into a new ``FlagGroup``
    func beginGroup<Container>(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<Container>) where Container: FlagContainer

    /// Called when finished visiting a ``FlagGroup``
    func endGroup(keyPath: FlagKeyPath)

    /// Called when visiting a flag. Provided parameters include closures you can
    /// use to grab the current or real-time flag values.
    ///
    /// - Parameters:
    ///   - keyPath:        The ``FlagKeyPath`` where the flag is found at.
    ///   - value:          A closure you can use to obtain the current flag value.
    ///   - defaultValue:   The hardcoded default value of the flag if it is not overridden by ``FlagValueSource``s.
    ///   - wigwag:         A closure you can use to obtain the flag's WigWag. You can obtain additional information
    ///                     about the flag or subscribe to real-time flag value changes via the WigWag.
    ///
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

    func beginContainer<Container>(keyPath: FlagKeyPath, containerType: Container.Type) {
        // Intentionally left blank
    }

    func endContainer(keyPath: FlagKeyPath) {
        // Intentionally left blank
    }

    func beginGroup<Container>(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<Container>) where Container: FlagContainer {
        // Intentionally left blank
    }

    func endGroup(keyPath: FlagKeyPath) {
        // Intentionally left blank
    }

}
