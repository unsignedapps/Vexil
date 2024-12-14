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

#if !os(Linux)
import Combine
#endif

import Foundation

/// A `Snapshot` serves multiple purposes in Vexil. It is a point-in-time container of flag values, and is also
/// mutable and can be applied / saved to a `FlagValueSource`.
///
/// `Snapshot`s are themselves a `FlagValueSource`, which means you can insert in into a `FlagPole`s
/// source hierarchy as required.,
///
/// You create snapshots using a `FlagPole`:
///
/// ```swift
/// // Create an empty Snapshot. It contains no values itself so any flags
/// // accessed in it will use their `defaultValue`.
/// let empty = flagPole.emptySnapshot()
///
/// // Create a full Snapshot. The current value of *all* flags in the `FlagPole`
/// // will be copied into it.
/// let snapshot = flagPole.snapshot()
/// ```
///
/// Snapshots can be manipulated:
///
/// ```swift
/// snapshot.subgroup.myAmazingFlag = "somevalue"
/// ````
///
/// Snapshots can be saved or applied to a `FlagValueSource`:
///
/// ```swift
/// try flagPole.save(snapshot: snapshot, to: UserDefaults.standard)
/// ```
///
/// Snapshots can be inserted into the `FlagPole`s source hierarchy:
///
/// ```swift
/// flagPole.insert(snapshot: snapshot, at: 0)
/// ```
///
/// And Snapshots are emitted from a `FlagPole` when you subscribe to real-time flag updates:
///
/// ```swift
/// flagPole.publisher
///     .sink { snapshot in
///         // ...
///     }
/// ```
///
@dynamicMemberLookup
public final class Snapshot<RootGroup>: Sendable where RootGroup: FlagContainer {

    // MARK: - Properties

    /// All `Snapshot`s are `Identifiable`
    public let id = UUID().uuidString

    /// An optional display name to use in flag editors like Vexillographer.
    public let displayName: String?

    // MARK: - Internal Properties

    private let rootKeyPath: FlagKeyPath

    let values: Lock<[String: any FlagValue]>

    var rootGroup: RootGroup {
        RootGroup(_flagKeyPath: rootKeyPath, _flagLookup: self)
    }

    let stream: StreamManager.Stream


    // MARK: - Initialisation

    init(
        flagPole: FlagPole<RootGroup>,
        copyingFlagValuesFrom source: Source?,
        keys: Set<String>? = nil,
        displayName: String? = nil
    ) {
        self.rootKeyPath = flagPole.rootKeyPath
        self.values = .init(initialState: [:])
        self.displayName = displayName
        self.stream = StreamManager.Stream(keyPathMapper: flagPole._configuration.makeKeyPathMapper())

        if let source {
            populateValuesFrom(source, flagPole: flagPole, keys: keys)
        }
    }

    init(flagPole: FlagPole<RootGroup>, copyingFlagValuesFrom source: Source?, change: FlagChange, displayName: String? = nil) {
        self.rootKeyPath = flagPole.rootKeyPath
        self.values = .init(initialState: [:])
        self.displayName = displayName
        self.stream = StreamManager.Stream(keyPathMapper: flagPole._configuration.makeKeyPathMapper())

        if let source {
            switch change {
            case .all:
                populateValuesFrom(source, flagPole: flagPole, keys: nil)
            case let .some(keys):
                populateValuesFrom(source, flagPole: flagPole, keys: Set(keys.map(\.key)))
            }
        }
    }

    init(flagPole: FlagPole<RootGroup>, snapshot: Snapshot<RootGroup>, displayName: String? = nil) {
        self.rootKeyPath = flagPole.rootKeyPath
        self.values = snapshot.values
        self.displayName = displayName
        self.stream = StreamManager.Stream(keyPathMapper: flagPole._configuration.makeKeyPathMapper())
    }


    // MARK: - Flag Management

    /// A `@DynamicMemberLookup` implementation that returns a `MutableFlagGroup` in place of a `FlagGroup`.
    /// The `MutableFlagGroup` provides a setter for the `Flag`s it contains, allowing them to be mutated as required.
    public subscript<Subgroup>(dynamicMember dynamicMember: KeyPath<RootGroup, Subgroup>) -> MutableFlagContainer<Subgroup> where Subgroup: FlagContainer {
        MutableFlagContainer(group: rootGroup[keyPath: dynamicMember], source: self)
    }

    /// A `@DynamicMemberLookup` implementation that returns a `Flag.wrappedValue` and allows them to be mutated.
    ///
    public subscript<Value>(dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value where Value: FlagValue {
        get {
            rootGroup[keyPath: dynamicMember]
        }
        set {
            if let keyPath = rootGroup._allFlagKeyPaths[dynamicMember] {
                values.withLock {
                    $0[keyPath.key] = newValue
                }
            }
        }
    }

    func save(to source: some FlagValueSource) throws {
        // Walking the root group requires looking up values so don't wrap the rest in the lock
        let keys = values.withLock { Set($0.keys) }
        let setter = FlagSetter(source: source, keys: keys)
        try setter.apply(to: rootGroup)
    }


    // MARK: - Population

    private func populateValuesFrom(_ source: Source, flagPole: FlagPole<RootGroup>, keys: Set<String>?) {
        let builder: Snapshot.Builder = switch source {
        case .pole:
            Builder(flagPole: flagPole, source: nil, rootKeyPath: flagPole.rootKeyPath, keys: keys)
        case let .source(flagValueSource):
            Builder(flagPole: nil, source: flagValueSource, rootKeyPath: flagPole.rootKeyPath, keys: keys)
        }
        values.withLock {
            $0 = builder.build()
        }
    }

    func set(_ value: (some FlagValue)?, key: String) {
        values.withLock {
            if let value {
                $0[key] = value
            } else {
                $0.removeValue(forKey: key)
            }
        }

        stream.send(.some([ FlagKeyPath(key, separator: rootKeyPath.separator) ]))
    }


    // MARK: - Source

    /// The source that we are to copy flag values from, if any
    enum Source {
        case pole
        case source(any FlagValueSource)

        var flagValueSource: (any FlagValueSource)? {
            switch self {
            case .pole:                     nil
            case let .source(source):       source
            }
        }
    }

}
