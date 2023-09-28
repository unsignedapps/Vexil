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
public class Snapshot<RootGroup> where RootGroup: FlagContainer {

    typealias LocatedFlag = (value: Any, sourceName: String?)

    // MARK: - Properties

    /// All `Snapshot`s are `Identifiable`
    public let id = UUID().uuidString

    /// An optional display name to use in flag editors like Vexillographer.
    public var displayName: String?

    // MARK: - Internal Properties

    internal var diagnosticsEnabled: Bool
    private var rootKeyPath: FlagKeyPath

    internal private(set) var values: [String: LocatedFlag] = [:]

    private var rootGroup: RootGroup {
        RootGroup(_flagKeyPath: rootKeyPath, _flagLookup: self)
    }

    let stream = StreamManager.Stream()


    // MARK: - Initialisation

    internal init(flagPole: FlagPole<RootGroup>, copyingFlagValuesFrom source: Source?, keys: Set<String>? = nil, diagnosticsEnabled: Bool = false) {
        self.diagnosticsEnabled = diagnosticsEnabled
        self.rootKeyPath = flagPole.rootKeyPath

        if let source {
            populateValuesFrom(source, flagPole: flagPole, keys: keys)
        }
    }

    internal init(flagPole: FlagPole<RootGroup>, snapshot: Snapshot<RootGroup>) {
        self.diagnosticsEnabled = flagPole.diagnosticsEnabled
        self.rootKeyPath = flagPole.rootKeyPath
        self.values = snapshot.values
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
                values[keyPath.key] = (value: newValue, sourceName: name)
            }
        }
    }

    func save(to source: any FlagValueSource) throws {
        let keys = Set(values.keys.map({ FlagKeyPath($0, separator: rootKeyPath.separator) }))
        let saver = FlagSaver(source: source, flags: keys)
        rootGroup.walk(visitor: saver)
        if let error = saver.error {
            throw error
        }
    }


    // MARK: - Population

    private func populateValuesFrom(_ source: Source, flagPole: FlagPole<RootGroup>, keys: Set<String>?) {
        let builder: Snapshot.Builder
        switch source {
        case .pole:
            builder = Builder(flagPole: flagPole, source: nil, rootKeyPath: flagPole.rootKeyPath, keys: keys)
        case let .source(flagValueSource):
            builder = Builder(flagPole: nil, source: flagValueSource, rootKeyPath: flagPole.rootKeyPath, keys: keys)
        }
        values = builder.build()
    }

    public func visitFlag(keyPath: FlagKeyPath, value: some Any, sourceName: String?) {
        values[keyPath.key] = (value, sourceName)
    }

    internal func set(_ value: (some FlagValue)?, key: String) {
        if let value {
            values[key] = (value, name)
        } else {
            values.removeValue(forKey: key)
        }

        stream.send(.some([ FlagKeyPath(key, separator: rootKeyPath.separator) ]))
    }


    // MARK: - Working with other Snapshots

//    internal func merge(_ other: Snapshot<RootGroup>) {
//        for value in other.values {
//            self.values.updateValue(value.value, forKey: value.key)
//        }
//    }


    // MARK: - Errors

//    enum Error: Swift.Error {
//        case flagKeyNotFound(String)
//    }


    // MARK: - Source

    /// The source that we are to copy flag values from, if any
    enum Source {
        case pole
        case source(any FlagValueSource)

        var flagValueSource: (any FlagValueSource)? {
            switch self {
            case .pole:                     return nil
            case let .source(source):       return source
            }
        }
    }


    // MARK: - Diagnostics

    /// Returns the current diagnostic state of all flags copied into this Snapshot.
    ///
    /// This method is intended to be called from the debugger
    ///
    /// - Important: You must enable diagnostics by setting `enableDiagnostics` to true in your ``VexilConfiguration``
    /// when initialising your FlagPole. Otherwise this method will throw a ``FlagPoleDiagnostic/Error/notEnabledForSnapshot`` error.
    ///
//    public func makeDiagnostics() throws -> [FlagPoleDiagnostic] {
//        guard self.diagnosticsEnabled == true else {
//            throw FlagPoleDiagnostic.Error.notEnabledForSnapshot
//        }
//
//        return .init(current: self)
//    }


}
