//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import AsyncAlgorithms

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
public final class FlagPole<RootGroup>: Sendable where RootGroup: FlagContainer {

    // MARK: - Properties

    /// The configuration information supplied to the `FlagPole` during initialisation.
    public let _configuration: VexilConfiguration

    /// Primary storage
    let manager: Lock<StreamManager>


    // MARK: - Sources

    /// An Array of `FlagValueSource`s that are used during flag value lookup.
    /// The order of this Array is the order used when looking up flag values.
    ///
    /// To update the list of sources use ``
    ///
    public var _sources: [any FlagValueSource] {
        manager.withLockUnchecked {
            $0.sources
        }
    }

    /// Updates the list of `FlagValueSource`s using the supplied closure.
    ///
    /// - Parameters:
    ///   - closure:        A closure that is passed a mutable copy of the sources array.
    ///
    public func updateSources(_ closure: (inout [any FlagValueSource]) throws -> Void) rethrows {
        try manager.withLockUnchecked { manager in
            let oldValue = manager.sources
            var copy = manager.sources
            try closure(&copy)
            manager.sources = copy

            if oldValue.map(\.flagValueSourceID) != copy.map(\.flagValueSourceID) {
                subscribeChannel(oldSources: oldValue, newSources: copy, on: &manager)
            }
        }
    }

    /// The default sources to use when they are not specified during `init()`.
    ///
    /// The current default sources include:
    ///   - `UserDefaults.standard`
    ///
    public static var defaultSources: [any FlagValueSource] {
#if !os(Linux)
#if swift(>=6)
        [ FlagValueSourceCoordinator(source: UserDefaults.standard) ]
#else
        [ FlagValueSourceCoordinator(uncheckedSource: UserDefaults.standard) ]
#endif
#else
        []
#endif
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
    public init(hoist: RootGroup.Type, configuration: VexilConfiguration = .default, sources: [any FlagValueSource]? = nil) {
        self._configuration = configuration
        self.manager = Lock(uncheckedState: StreamManager(sources: sources ?? Self.defaultSources))
    }

    deinit {
        manager.withLock { manager in
            for task in manager.tasks {
                task.1.cancel()
            }
        }
    }


    // MARK: - Flag Management

    var rootKeyPath: FlagKeyPath {
        let root = FlagKeyPath.root(separator: _configuration.separator, strategy: _configuration.codingPathStrategy)
        if let prefix = _configuration.prefix {
            return root.append(.customKey(prefix))
        } else {
            return root
        }
    }

    var rootGroup: RootGroup {
        RootGroup(_flagKeyPath: rootKeyPath, _flagLookup: self)
    }

    /// A `@dynamicMemberLookup` implementation that allows you to access the `Flag` and `FlagGroup`s contained
    /// within `self._rootGroup`
    public subscript<Value>(dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value {
        rootGroup[keyPath: dynamicMember]
    }

    /// Walks the provided ``FlagVisitor`` across the flag hierarchy. Your visitor is informed
    /// of every FlagGroup or Flag visited, allowing you to inspect the hierarchy and react as required.
    public func walk(visitor: any FlagVisitor) {
        rootGroup.walk(visitor: visitor)
    }


    // MARK: - Real Time Changes

    /// An `AsyncSequence` that can be used to monitor flag changes in real-time.
    ///
    /// A sequence of `FlagChange` elements are returned which describe changes to flags.
    ///
    public var changes: FlagChangeStream {
        stream.stream
    }

    /// An `AsyncSequence` that can be used to monitor flag value changes in real-time.
    ///
    /// A new `RootGroup` is emitted _immediately_, and then every time flags are believed to change changed.
    ///
    public var flags: AsyncChain2Sequence<AsyncSyncSequence<[RootGroup]>, AsyncMapSequence<FlagChangeStream, RootGroup>> {
        let flagStream = changes
            .map { _ in
                self.rootGroup
            }

        return chain([ rootGroup ].async, flagStream)
    }

    public var snapshots: AsyncChain2Sequence<AsyncSyncSequence<[Snapshot<RootGroup>]>, AsyncCompactMapSequence<AsyncPrefixWhileSequence<AsyncMapSequence<FlagChangeStream, Snapshot<RootGroup>?>>, Snapshot<RootGroup>>> {
        let snapshotStream = changes
            .map { [weak self] change in
                self?.snapshot(including: change)
            }
            .prefix(while: { $0 != nil })               // close the stream when we get nil back
            .compactMap { $0 }

        return chain([ snapshot() ].async, snapshotStream)
    }

#if canImport(Combine)

    /// A `Publisher` that can be used to monitor flag changes in real-time.
    ///
    /// A sequence of `FlagChange`  elements are emitted which describe changes to flags. ``FlagChange/all``
    /// indicates an assumption that all flag values MAY have changed, and ``FlagChange/some(_:)``
    /// will list the keys of the flags that are known to have changed.
    ///
    public var changePublisher: some Combine.Publisher<FlagChange, Never> {
        FlagPublisher(changes)
    }

    /// A `Publisher` that will emit every time one or more flag values have changed.
    ///
    /// A new `RootGroup` is emitted _immediately_, and then every time flags are believed to have changed.
    /// Because `RootGroup` looks up flags live they are not guaranteed to be stable between emitted
    /// values. If you need them to be stable use ``snapshotPublisher`` instead, which takes a snapshot
    /// of the `RootGroup` and emits that whenever flag values change.
    ///
    public var flagPublisher: some Combine.Publisher<RootGroup, Never> {
        changePublisher
            .map { [weak self] _ -> AnyPublisher<RootGroup, Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return Just(rootGroup).eraseToAnyPublisher()
            }
            .switchToLatest()
            .prepend(rootGroup)
    }

    private let _snapshotPublisher = Lock<Publishers.Autoconnect<Publishers.Multicast<Publishers.Drop<FlagPublisher<AsyncChain2Sequence<AsyncSyncSequence<[Snapshot<RootGroup>]>, AsyncCompactMapSequence<AsyncPrefixWhileSequence<AsyncMapSequence<FlagChangeStream, Snapshot<RootGroup>?>>, Snapshot<RootGroup>>>>>, CurrentValueSubject<AsyncChain2Sequence<AsyncSyncSequence<[Snapshot<RootGroup>]>, AsyncCompactMapSequence<AsyncPrefixWhileSequence<AsyncMapSequence<FlagChangeStream, Snapshot<RootGroup>?>>, Snapshot<RootGroup>>>.Element, Never>>>?>(uncheckedState: nil)

    /// A `Publisher` that will emit a snapshot of the flag pole every time flag values have changed.
    ///
    /// A new ``Snapshot`` is emitted _immediately_, and then every time flag values are believed to have changed.
    /// Snapshotted values are guaranteed not to change, but comes at the performance cost of performing a
    /// lookup on every changed flag value every time they change, even if you don't use those values in the
    /// emitted snapshot. If you don't need that guarantee you should try ``flagPublisher`` which merely
    /// provides a new `RootGroup` whenever flag values have changed without the implicit lookup.
    ///
    /// - Note: This publisher will be shared between callers so that only one snapshot will need to be
    /// taken per flag change, not one per flag change per subscriber.
    ///
    public var snapshotPublisher: some Combine.Publisher<Snapshot<RootGroup>, Never> {
        _snapshotPublisher.withLockUnchecked { cached in
            if let cached {
                return cached
            }
            let current = snapshot()
            let publisher = FlagPublisher(snapshots)
                .dropFirst()                            // this could be out of date compared to the snapshot we just took
                .multicast { CurrentValueSubject(current) }
                .autoconnect()
            cached = publisher
            return publisher
        }
    }

    /// A `Publisher` that will emit a snapshot of the flag pole every time flag values have changed.
    ///
    /// A new ``Snapshot`` is emitted _immediately_, and then every time flag values are believed to have changed.
    /// Snapshotted values are guaranteed not to change, but comes at the performance cost of performing a
    /// lookup on every changed flag value every time they change, even if you don't use those values in the
    /// emitted snapshot. If you don't need that guarantee you should try ``flagPublisher`` which merely
    /// provides a new `RootGroup` whenever flag values have changed without the implicit lookup.
    ///
    /// - Note: This publisher will be shared between callers so that only one snapshot will need to be
    /// taken per flag change, not one per flag change per subscriber.
    ///
    @available(*, deprecated, renamed: "snapshotPublisher", message: "Will be removed in a future version. Renamed to `FlagPole.snapshotPublisher` but you should consider `FlagPole.flagPublisher` instead for better performance.")
    public var publisher: some Combine.Publisher<Snapshot<RootGroup>, Never> {
        snapshotPublisher
    }

#endif


    // MARK: - Snapshots

    /// Creates a `Snapshot` of the current state of the `FlagPole` (or optionally a
    /// `FlagValueSource`)
    ///
    /// - Parameters:
    ///   - source:         An optional `FlagValueSource` to copy values from. If this is omitted
    ///                     or nil then the values of each `Flag` within the `FlagPole` is copied
    ///                     into the snapshot instead.
    ///   - change:         A ``FlagChange`` (as emitted from ``changes`` or ``changePublisher``).
    ///                     Only changes described by the `change` will be included in the snapshot.
    ///   - displayName:    An optional display name for the snapshot that gets shown in editors like Vexillographer.
    ///
    public func snapshot(of source: (any FlagValueSource)? = nil, including change: FlagChange = .all, displayName: String? = nil) -> Snapshot<RootGroup> {
        Snapshot(
            flagPole: self,
            copyingFlagValuesFrom: source.flatMap(Snapshot.Source.source) ?? .pole,
            change: change,
            displayName: displayName
        )
    }

    /// Creates an empty `Snapshot` of the current `FlagPole`.
    ///
    /// The snapshot itself will be empty and access to any flags
    /// within the snapshot will return the flag's `defaultValue`.
    ///
    /// - Parameters:
    ///   - displayName:    An optional display name for the snapshot that gets shown in editors like Vexillographer.
    ///
    public func emptySnapshot(displayName: String? = nil) -> Snapshot<RootGroup> {
        Snapshot(flagPole: self, copyingFlagValuesFrom: nil, displayName: displayName)
    }

    /// Inserts a `Snapshot` into the `FlagPole`s source hierarchy at the specified index.
    ///
    /// Inserting a snapshot at the top of the hierarchy (eg at index `0`) is a good way to
    /// override the values in the FlagPole without saving it to a source, but you can also
    /// insert it anywhere in the hierarchy you need.
    ///
    /// - Note: You can also manipulate `_sources` directly.
    ///
    /// - Parameters:
    ///   - snapshot:       The `Snapshot` to be inserted
    ///   - at:             The index at which to insert the `Snapshot`.
    ///
    public func insert(snapshot: Snapshot<RootGroup>, at index: Array<any FlagValueSource>.Index) {
        updateSources {
            $0.insert(snapshot, at: index)
        }
    }

    /// Appends a `Snapshot` to the end of the `FlagPole`s source hierarchy.
    ///
    /// - Note: You can also manipulate `_sources` directly.
    ///
    /// - Parameters:
    ///   - snapshot:       The `Snapshot` to be added to the source hierarchy.
    ///
    public func append(snapshot: Snapshot<RootGroup>) {
        updateSources {
            $0.append(snapshot)
        }
    }

    /// Removes a `Snapshot` from the `FlagPole`s source hierarchy.
    ///
    /// - Note: You can also manipulate `_sources` directly.
    ///
    /// - Parameters:
    ///   - snapshot:       The `Snapshot` to be removed from the source hierarchy.
    ///
    public func remove(snapshot: Snapshot<RootGroup>) {
        updateSources {
            $0.removeAll(where: { ($0 as? Snapshot<RootGroup>)?.id == snapshot.id })
        }
    }


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
    public func save(snapshot: Snapshot<RootGroup>, to source: some FlagValueSource) throws {
        try snapshot.save(to: source)
    }


    // MARK: - Mutating Flag Values

    /// Copies the flag values from the current `FlagPole` to some `FlagValueSource`.
    ///
    /// ```swift
    /// /// Copies all flags on the flag pole into the provided dictionary
    /// let dictionary = FlagValueDictionary()
    /// try flagPole.copyFlagValues(to: dictionary)
    /// ```
    ///
    public func copyFlagValues(to destination: some FlagValueSource) throws {
        let snapshot = snapshot()
        try save(snapshot: snapshot, to: destination)
    }

    /// Copies the flag values from one `FlagValueSource` to another.
    ///
    /// If the `from` source is `nil` then the values will be copied from the `FlagPole` into
    /// the `to` source.
    ///
    /// ```swift
    /// /// Copies any flags currently saved in the `UserDefaults` to a `FlagValueDictionary`
    /// let defaults = UserDefaults.standard
    /// let dictionary = FlagValueDictionary()
    /// try flagPole.copyFlagValues(from: defaults, to: dictionary)
    /// ```
    ///
    public func copyFlagValues(from source: some FlagValueSource, to destination: some FlagValueSource) throws {
        let snapshot = snapshot(of: source)
        try save(snapshot: snapshot, to: destination)
    }

    /// Removes all of the flag values from the specified flag value source.
    ///
    /// All flag values for the given source are expected to return `nil` after this
    /// method is called. This is useful if you want to provide a button or the capability
    /// to "reset" a source back to its defaults, or clear any overrides in the given source.
    ///
    public func removeFlagValues(in source: some FlagValueSource) throws {
        let remover = FlagRemover(source: source)
        try remover.apply(to: rootGroup)
    }

}


// MARK: - Debugging

extension FlagPole: CustomDebugStringConvertible {
    public var debugDescription: String {
        let visitor = DebugDescriptionVisitor()
        walk(visitor: visitor)
        return "FlagPole<\(String(describing: RootGroup.self))>(\(visitor.valueDescriptions.joined(separator: "; ")))"
    }
}

private final class DebugDescriptionVisitor: FlagVisitor {

    var valueDescriptions = [String]()

    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue {
        guard let value = value() else {
            valueDescriptions.append("\(keyPath.key)=nil")
            return
        }

        if let debug = value as? CustomDebugStringConvertible {
            valueDescriptions.append("\(keyPath.key)=\(debug)")
        } else if let description = value as? CustomStringConvertible {
            valueDescriptions.append("\(keyPath.key)=\(description)")
        } else {
            valueDescriptions.append("\(keyPath.key)=\(value)")
        }
    }

}
