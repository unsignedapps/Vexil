//
//  FlagPole.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

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

            if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                self.setupSnapshotPublishing(sendImmediately: true)
            }

            #endif
        }
    }

    /// The default sources to use when they are not specified during `init()`.
    ///
    /// The current default sources include:
    ///   - `UserDefaults.standard`
    ///
    public static var defaultSources: [FlagValueSource] {
        return [
            UserDefaults.standard
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
    public convenience init (hoist: RootGroup.Type, configuration: VexilConfiguration = .default, sources: [FlagValueSource]? = nil) {
        self.init(hoisting: RootGroup(), configuration: configuration, sources: sources)
    }

    internal init (hoisting: RootGroup, configuration: VexilConfiguration = .default, sources: [FlagValueSource]? = nil) {
        self._rootGroup = hoisting
        self._configuration = configuration
        self._sources = sources ?? Self.defaultSources
        self.decorateRootGroup()

        #if !os(Linux)

        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            self.setupSnapshotPublishing(sendImmediately: false)
        }

        #endif
    }


    // MARK: - Flag Management

    /// The "Root Group" that  contains your Flag tree/hierarchy.
    public var _rootGroup: RootGroup

    /// A `@dynamicMemberLookup` implementation that allows you to access the `Flag` and `FlagGroup`s contained
    /// within `self._rootGroup`
    ///
    public subscript<Value> (dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value {
        return self._rootGroup[keyPath: dynamicMember]
    }

    /// Starts the decoration process. Called during `init()` to make sure that
    /// all `Flag` and `FlagGroup`s contained within `RootGroup` have their keys calcualted
    /// and sets a weak reference to ourselves that they can use to lookup the flag values.
    ///
    private func decorateRootGroup () {

        var codingPath: [String] = []
        if let prefix = self._configuration.prefix {
            codingPath.append(prefix)
        }

        Mirror(reflecting: self._rootGroup)
            .children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: self, label: $0.label, codingPath: codingPath, config: self._configuration)
            }
    }


    // MARK: - Real Time Changes

    #if !os(Linux)

    /// An internal state variable used so we don't setup the `Publisher` infrastructure
    /// until someone has accessed `self.publisher`
    private var shouldSetupSnapshotPublishing = false

    /// An internal reference to the latest snapshot as emitted by our `FlagValueSource`s
    private lazy var latestSnapshot: CurrentValueSubject<Snapshot<RootGroup>, Never> = {
        return CurrentValueSubject(self.snapshot())
    }()

    /// A `Publisher` that can be used to monitor flag value changes in real-time.
    ///
    /// A new `Snapshot` is emitted every time a flag value changes. The snapshot
    /// contains the latest state of all flag values in the tree.
    ///
    public var publisher: AnyPublisher<Snapshot<RootGroup>, Never> {
        let snapshot = self.latestSnapshot
        if self.shouldSetupSnapshotPublishing == false {
            self.shouldSetupSnapshotPublishing = true
            self.setupSnapshotPublishing(sendImmediately: true)
        }
        return snapshot.eraseToAnyPublisher()
    }

    private lazy var cancellables = Set<AnyCancellable>()

    private func setupSnapshotPublishing (sendImmediately: Bool) {
        guard self.shouldSetupSnapshotPublishing else { return }

        // cancel our existing one
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

        let upstream = self._sources.compactMap { $0.valuesDidChange }

        Publishers.MergeMany(upstream)
            .sink { [weak self] in
                guard let self = self else { return }
                self.latestSnapshot.send(self.snapshot())
            }
            .store(in: &self.cancellables)

        if sendImmediately {
            self.latestSnapshot.send(self.snapshot())
        }
    }

    #endif

    // MARK: - Snapshots

    /// Creates a `Snapshot` of the current state of the `FlagPole`
    ///
    /// The value of each `Flag` within the `FlagPole` is copied into the snapshot.
    ///
    public func snapshot () -> Snapshot<RootGroup> {
        return Snapshot(flagPole: self, copyCurrentFlagValues: true)
    }

    /// Creates an empty `Snapshot` of the current `FlagPole`.
    ///
    /// The snapshot itself will be empty and access to any flags
    /// within the snapshot will return the flag's `defaultValue`.
    ///
    public func emptySnapshot () -> Snapshot<RootGroup> {
        return Snapshot(flagPole: self, copyCurrentFlagValues: false)
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
    public func insert (snapshot: Snapshot<RootGroup>, at index: Array<FlagValueSource>.Index) {
        self._sources.insert(snapshot, at: index)

    }

    /// Appends a `Snapshot` to the end of the `FlagPole`s source hierarchy.
    ///
    /// - Note: You can also manipulate `_sources` directly.
    ///
    /// - Parameters:
    ///   - snapshot:       The `Snapshot` to be added to the source hierarchy.
    ///
    public func append (snapshot: Snapshot<RootGroup>) {
        self._sources.append(snapshot)
    }

    /// Removes a `Snapshot` from the `FlagPole`s source hierarchy.
    ///
    /// - Note: You can also manipulate `_sources` directly.
    ///
    /// - Parameters:
    ///   - snapshot:       The `Snapshot` to be removed from the source hierarchy.
    ///
    public func remove (snapshot: Snapshot<RootGroup>) {
        self._sources.removeAll(where: { ($0 as? Snapshot<RootGroup>)?.id == snapshot.id })
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
    public func save (snapshot: Snapshot<RootGroup>, to source: FlagValueSource) throws {
        try snapshot.changedFlags()
            .forEach { try $0.save(to: source) }
    }
}
