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

/// A `FlagPole` hoists a group of feature flags / feature toggles.
///
/// It provides the primary mechanism for dynamically accessing `Flag`s, looking
/// them up from multiple sources. It also provides methods for taking and interaction
/// with `Snapshot`s of flags.
///
/// Each `FlagPole` must be initalised with the type of a `FlagContainer`:
///
/// ```swift
/// struct MyFlags: FlagContainer {
///     // ...
/// }
///
/// let flagPpole = FlagPole(hoist: MyFlags.self)
/// ```
///
/// You can then interact with the `FlagPole` using dynamic member lookup:
///
/// ```swift
/// if flagPole.myFlag == true { ... }
/// ```
///
/// - Note: Where possible, properties directly on `FlagPole` have been prefixed with an underscore (`_`)
///         so as not to conflict with the dynamic member properties on your `FlagContainer`.
///
@dynamicMemberLookup
public class FlagPole<RootGroup> where RootGroup: FlagContainer {

    // MARK: - Configuration

    /// The configuration information supplied to the `FlagPole` during initialisation.
    public let _configuration: VexilConfiguration


    // MARK: - Sources

    /// An Array of `FlagValueSource`s that are used during flag value lookup.
    ///
    /// This array is mutable so you can manipulate it directly whenever your
    /// need to change the hierarchy of your flag sources.
    ///
    /// The order of this Array is the order used when looking up flag values.
    ///
    public var _sources: [FlagValueSource] {
        didSet {
#if !os(Linux)

//            if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
//                let oldSourceNames = oldValue.map(\.name)
//                let newSourceNames = _sources.map(\.name)
//
//                self.setupSnapshotPublishing(
//                    keys: self.allFlagKeys,
//                    sendImmediately: true,
//                    changedSources: oldSourceNames.difference(from: newSourceNames).map(\.element)
//                )
//            }

#endif
        }
    }

    /// The default sources to use when they are not specified during `init()`.
    ///
    /// The current default sources include:
    ///   - `UserDefaults.standard`
    ///
    public static var defaultSources: [FlagValueSource] {
        [
            UserDefaults.standard,
        ]
    }


    // MARK: - Initialisation

    /// Initialises a `FlagPole` with the supplied info.
    ///
    /// At minimum you need to provide a type that contains all of your `Flag` and `FlagGroup`s that conforms to `FlagContainer`.
    /// You can also specify how flag keys should be calculated and an array of flag value sources.
    ///
    /// - Parameters:
    ///   - hoist:              The type of `FlagContainer` to hoist. eg. `MyFlags.self`
    ///   - configuration:      An optional configuration describing how `Flag` keys should be calculated. Defaults to `VexilConfiguration.default`
    ///   - sources:            An optional Array of `FlagValueSource`s to use as the flag pole's source hierarchy. Defaults to `FlagPole.defaultSources`
    ///
    public init(hoist: RootGroup.Type, configuration: VexilConfiguration = .default, sources: [FlagValueSource]? = nil) {
        self._configuration = configuration
        self._sources = sources ?? Self.defaultSources

#if !os(Linux)

//        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
//            self.setupSnapshotPublishing(keys: self.allFlagKeys, sendImmediately: false)
//        }

#endif
    }


    // MARK: - Flag Management

    /// A `@dynamicMemberLookup` implementation that allows you to access the `Flag` and `FlagGroup`s contained
    /// within `self._rootGroup`
    ///
    public subscript<Value>(dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value {
        RootGroup(_lookup: self)[keyPath: dynamicMember]
    }


    // MARK: - Real Time Changes

#if !os(Linux)

//    /// An internal state variable used so we don't setup the `Publisher` infrastructure
//    /// until someone has accessed `self.publisher`
//    private var shouldSetupSnapshotPublishing = false
//
//    /// An internal reference to the latest snapshot as emitted by our `FlagValueSource`s
//    private lazy var latestSnapshot: CurrentValueSubject<Snapshot<RootGroup>, Never> = CurrentValueSubject(self.snapshot())
//
//    /// A `Publisher` that can be used to monitor flag value changes in real-time.
//    ///
//    /// A new `Snapshot` is emitted every time a flag value changes. The snapshot
//    /// contains the latest state of all flag values in the tree.
//    ///
//    public var publisher: AnyPublisher<Snapshot<RootGroup>, Never> {
//        let snapshot = self.latestSnapshot
//        if self.shouldSetupSnapshotPublishing == false {
//            self.shouldSetupSnapshotPublishing = true
//            self.setupSnapshotPublishing(keys: self.allFlagKeys, sendImmediately: false)
//        }
//        return snapshot.eraseToAnyPublisher()
//    }
//
//    private lazy var cancellables = Set<AnyCancellable>()
//
//    private func setupSnapshotPublishing(keys: Set<String>, sendImmediately: Bool, changedSources: [String]? = nil) {
//        guard self.shouldSetupSnapshotPublishing else {
//            return
//        }
//
//        // cancel our existing one
//        self.cancellables.forEach { $0.cancel() }
//        self.cancellables.removeAll()
//
//        let upstream = self._sources
//            .compactMap { source -> AnyPublisher<(String, Set<String>), Never>? in
//                let maybePublisher = source.valuesDidChange(keys: keys)
//                    ?? source.valuesDidChange?.map { _ in [] }.eraseToAnyPublisher()   // backwards compatibility
//
//                guard let publisher = maybePublisher else {
//                    return nil
//                }
//
//                let name = source.name
//                return publisher
//                    .map { (name, $0) }
//                    .eraseToAnyPublisher()
//            }
//
//        Publishers.MergeMany(upstream)
//            .sink { [weak self] source, keys in
//                guard let self else {
//                    return
//                }
//
//                let snapshot = Snapshot(flagPole: self, snapshot: self.latestSnapshot.value)
//                let changed = Snapshot(flagPole: self, copyingFlagValuesFrom: .pole, keys: keys.isEmpty == true ? nil : keys, diagnosticsEnabled: self._diagnosticsEnabled)
//                snapshot.merge(changed)
//                self.latestSnapshot.send(snapshot)
//
//                if self._diagnosticsEnabled == true {
//                    self.diagnosticSubject.send(.init(changed: changed, sources: [source]))
//                }
//            }
//            .store(in: &self.cancellables)
//
//        if sendImmediately {
//            let snapshot = self.snapshot()
//            self.latestSnapshot.send(snapshot)
//            if self._diagnosticsEnabled == true {
//                self.diagnosticSubject.send(.init(changed: snapshot, sources: changedSources))
//            }
//        }
//    }

#endif // !os(Linux)

    // MARK: - Diagnostics

//    var _diagnosticsEnabled = false
//
//    /// Returns the current diagnostic state of all flags managed by this FlagPole.
//    ///
//    /// This method is intended to be called from the debugger
//    ///
//    public func makeDiagnostics() -> [FlagPoleDiagnostic] {
//        .init(current: self.snapshot(enableDiagnostics: true))
//    }

#if !os(Linux)

//    private lazy var diagnosticSubject = PassthroughSubject<[FlagPoleDiagnostic], Never>()
//
//    /// A `Publisher` that can be used to monitor diagnostic outputs
//    ///
//    /// An array of `Diagnostic` messages is emitted every time a flag value changes. It can be one of two types:
//    ///
//    ///  - The value of every flag on the `FlagPole` at the time of subscribing, and which `FlagValueSource` it was resolved by
//    ///  - An array of the flag values that were changed, which `FlagValueSource` they were changed by, and their resolved value/source
//    ///
//    public func makeDiagnosticsPublisher() -> AnyPublisher<[FlagPoleDiagnostic], Never> {
//        let wasAlreadyEnabled = _diagnosticsEnabled
//        _diagnosticsEnabled = true
//
//        var snapshot = self.latestSnapshot.value
//
//        // if publishing hasn't been started yet (ie they've accessed `_diagnosticsPublisher` before `publisher`)
//        if self.shouldSetupSnapshotPublishing == false {
//            self.shouldSetupSnapshotPublishing = true
//            self.setupSnapshotPublishing(keys: self.allFlagKeys, sendImmediately: false)
//
//            // if publishing has already been started, but diagnostics were not previously enabled, we setup again to make sure they are available
//        } else if wasAlreadyEnabled == false {
//            snapshot = self.snapshot()
//            self.latestSnapshot.send(snapshot)
//        }
//
//        return diagnosticSubject
//            .prepend(.init(current: snapshot))
//            .eraseToAnyPublisher()
//    }

#endif // !os(Linux)


    // MARK: - Snapshots

//    /// Creates a `Snapshot` of the current state of the `FlagPole` (or optionally a
//    /// `FlagValueSource`)
//    ///
//    /// - Parameters:
//    ///   - source:         An optional `FlagValueSource` to copy values from. If this is omitted
//    ///                     or nil then the values of each `Flag` within the `FlagPole` is copied
//    ///                     into the snapshot instead.
//    ///
//    public func snapshot(of source: FlagValueSource? = nil, enableDiagnostics: Bool = false) -> Snapshot<RootGroup> {
//        Snapshot(
//            flagPole: self,
//            copyingFlagValuesFrom: source.flatMap(Snapshot.Source.source) ?? .pole,
//            diagnosticsEnabled: enableDiagnostics || self._diagnosticsEnabled
//        )
//    }
//
//    /// Creates an empty `Snapshot` of the current `FlagPole`.
//    ///
//    /// The snapshot itself will be empty and access to any flags
//    /// within the snapshot will return the flag's `defaultValue`.
//    ///
//    public func emptySnapshot() -> Snapshot<RootGroup> {
//        Snapshot(flagPole: self, copyingFlagValuesFrom: nil)
//    }
//
//    /// Inserts a `Snapshot` into the `FlagPole`s source hierarchy at the specified index.
//    ///
//    /// Inserting a snapshot at the top of the hierarchy (eg at index `0`) is a good way to
//    /// override the values in the FlagPole without saving it to a source, but you can also
//    /// insert it anywhere in the hierarchy you need.
//    ///
//    /// - Note: You can also manipulate `_sources` directly.
//    ///
//    /// - Parameters:
//    ///   - snapshot:       The `Snapshot` to be inserted
//    ///   - at:             The index at which to insert the `Snapshot`.
//    ///
//    public func insert(snapshot: Snapshot<RootGroup>, at index: Array<FlagValueSource>.Index) {
//        self._sources.insert(snapshot, at: index)
//
//    }
//
//    /// Appends a `Snapshot` to the end of the `FlagPole`s source hierarchy.
//    ///
//    /// - Note: You can also manipulate `_sources` directly.
//    ///
//    /// - Parameters:
//    ///   - snapshot:       The `Snapshot` to be added to the source hierarchy.
//    ///
//    public func append(snapshot: Snapshot<RootGroup>) {
//        self._sources.append(snapshot)
//    }
//
//    /// Removes a `Snapshot` from the `FlagPole`s source hierarchy.
//    ///
//    /// - Note: You can also manipulate `_sources` directly.
//    ///
//    /// - Parameters:
//    ///   - snapshot:       The `Snapshot` to be removed from the source hierarchy.
//    ///
//    public func remove(snapshot: Snapshot<RootGroup>) {
//        self._sources.removeAll(where: { ($0 as? Snapshot<RootGroup>)?.id == snapshot.id })
//    }


    // MARK: - Mutating Flag Sources

    /// Saves the specified `Snapshot` to the specified `FlagValueSource`.
    ///
    /// Only the values that are specifically included in the `Snapshot` will be saved.
    /// When you create a snapshot using `FlagPole.snapshot()`, all values are copied into the `Snapshot`.
    ///
    /// If you created your snapshot using `FlagPole.emptySnapshot()`, no values are included. Only values that
    /// subsequently **changed** using the dynamic member lookup support would then be saved to `source`:
    ///
    /// ```swift
    /// // Create an empty snapshot
    /// let snapshot = flagPole.emptySnapshot()
    ///
    /// // Change any flags you need to
    /// snapshot.subgroup.showMyTestFeature = true
    ///
    /// // Save that back to `UserDefaults`. Only `subgroup.show-my-test-feature` will be saved.
    /// try flagPole.save(snapshot: snapshot, to: UserDefaults.standard)
    /// ```
    ///
    /// - Parameters:
    ///   - snapshot:           The `Snapshot` to save to the source. Only the values included in the snapshot will be saved.
    ///   - to:                 The `FlagValueSource` to save the snapshot to.
    ///
//    public func save(snapshot: Snapshot<RootGroup>, to source: FlagValueSource) throws {
//        try snapshot.changedFlags()
//            .forEach { try $0.save(to: source) }
//    }


    // MARK: - Mutating Flag Values

    /// Copies the flag values from one `FlagValueSource` to another.
    ///
    /// If the `from` source is `nil` then the values will be copied from the `FlagPole` into
    /// the `to` source.
    ///
    /// ```swift
    /// /// Copies any flags currently saved in the `UserDefaults` to a `FlagValueDictionary`
    /// let defaults = UserDefaults.standard
    /// let dictionary = FlagValueDictionary()
    /// try flagPole.copy(from: defaults, to: dictionary)
    /// ```
    ///
//    public func copyFlagValues(from source: FlagValueSource?, to destination: FlagValueSource) throws {
//        let snapshot = self.snapshot(of: source)
//        try self.save(snapshot: snapshot, to: destination)
//    }

    /// Removes all of the flag values from the specified flag value source.
    ///
    /// All flag values for the given source are expected to return `nil` after this
    /// method is called. This is useful if you want to provide a button or the capability
    /// to "reset" a source back to its defaults, or clear any overrides in the given source.
    ///
//    public func removeFlagValues(in source: FlagValueSource) throws {
//        let flagsInSource = FlagValueDictionary()
//        try self.copyFlagValues(from: source, to: flagsInSource)
//
//        for key in flagsInSource.keys {
//
//            // setFlagValue<Value> needs to specialise the generic, so we picked `Bool` at
//            // random so we can pass in the nil
//            try source.setFlagValue(Bool?.none, key: key)
//        }
//    }

}


// MARK: - Debugging

//extension FlagPole: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        "FlagPole<\(String(describing: RootGroup.self))>("
//            + Mirror(reflecting: _rootGroup).children
//            .map { _, value -> String in
//                (value as? CustomDebugStringConvertible)?.debugDescription
//                    ?? (value as? CustomStringConvertible)?.description
//                    ?? String(describing: value)
//            }
//            .joined(separator: "; ")
//            + ")"
//    }
//}
