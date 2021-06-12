//
//  Snapshot.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

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

    // MARK: - Properties

    /// All `Snapshot`s are `Identifiable`
    public let id = UUID()

    /// An optional display name to use in flag editors like Vexillographer.
    public var displayName: String?


    // MARK: - Internal Properties

    internal var _rootGroup: RootGroup

    private(set) internal var values: [String: Any] = [:]

    internal var lock = Lock()

    internal var lastAccessedKey: String?


    // MARK: - Initialisation

    internal init (flagPole: FlagPole<RootGroup>, copyingFlagValuesFrom source: Source?, keys: [String]? = nil) {
        self._rootGroup = RootGroup()
        self.decorateRootGroup(config: flagPole._configuration)

        if let source = source {
            self.copyCurrentValues(source: source, keys: keys, flagPole: flagPole)
        }
    }

    internal init (flagPole: FlagPole<RootGroup>, snapshot: Snapshot<RootGroup>) {
        self._rootGroup = RootGroup()
        self.decorateRootGroup(config: flagPole._configuration)
        self.values = snapshot.values
    }


    // MARK: - Flag Management

    /// A `@DynamicMemberLookup` implementation that returns a `MutableFlagGroup` in place of a `FlagGroup`.
    /// The `MutableFlagGroup` provides a setter for the `Flag`s it contains, allowing them to be mutated as required.
    ///
    public subscript<Subgroup> (dynamicMember dynamicMember: KeyPath<RootGroup, Subgroup>) -> MutableFlagGroup<Subgroup, RootGroup> where Subgroup: FlagContainer {
        let group = self._rootGroup[keyPath: dynamicMember]
        return MutableFlagGroup<Subgroup, RootGroup>(group: group, snapshot: self)
    }

    /// A `@DynamicMemberLookup` implementation that returns a `Flag.wrappedValue` and allows them to be mutated.
    ///
    public subscript<Value> (dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value where Value: FlagValue {
        get {
            return self.lock.withLock {
                self._rootGroup[keyPath: dynamicMember]
            }
        }
        set {

            // This is pretty horrible, but it has to stay until we can find a way to
            // get the KeyPath of the property wrapper from the KeyPath of the wrappedValue
            // (eg. container.myFlag -> container._myFlag) or else the property
            // label from the KeyPath (so we can use reflection), or if the technique
            // here (https://forums.swift.org/t/getting-keypaths-to-members-automatically-using-mirror/21207/2)
            // returned KeyPaths that were equatable/hashable with the actual KeyPath,
            // or if the KeyPathIterable / StorePropertyIterable propsal
            // (https://forums.swift.org/t/storedpropertyiterable/19218/70) ever gets across the line

            self.lock.withLock {

                // noop to access the existing property
                _ = self._rootGroup[keyPath: dynamicMember]

                guard let key = self.lastAccessedKey else { return }
                self.set(newValue, key: key)

            }
        }
    }

    private var allFlags: [AnyFlag] = []

    private func decorateRootGroup (config: VexilConfiguration) {

        var codingPath: [String] = []
        if let prefix = config.prefix {
            codingPath.append(prefix)
        }

        let children = Mirror(reflecting: self._rootGroup).children

        children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: self, label: $0.label, codingPath: codingPath, config: config)
            }

        self.allFlags = children
            .lazy
            .map({ $0.value })
            .allFlags()
    }

    private func copyCurrentValues (source: Source, keys: [String]? = nil, flagPole: FlagPole<RootGroup>) {
        let flagValueSource = source.flagValueSource

        let flags = Mirror(reflecting: flagPole._rootGroup)
            .children
            .lazy
            .compactMap { $0.value }
            .allFlags()
            .filter { keys == nil || keys?.contains($0.key) == true }
            .compactMap { flag -> (String, Any)? in
                let value = flag.getFlagValue(in: flagValueSource)

                // we copy everything from FlagPoles but only what a source contains
                if flagValueSource != nil && value == nil {
                    return nil
                }

                return (flag.key, value as Any)
            }

        self.values = Dictionary(uniqueKeysWithValues: flags)
    }

    internal func changedFlags () -> [AnyFlag] {
        guard self.values.isEmpty == false else { return [] }

        let changed = self.values.keys
        return self.allFlags
            .filter { changed.contains($0.key) }
    }

    internal func set (_ value: Any?, key: String) {
        if let value = value {
            self.values[key] = value
        } else {
            self.values.removeValue(forKey: key)
        }

        self.valuesDidChange.send()
    }


    // MARK: - Working with other Snapshots

    internal func merge(_ other: Snapshot<RootGroup>) {
        for value in other.values {
            self.values.updateValue(value.value, forKey: value.key)
        }
    }


    // MARK: - Real Time Flag Changes

    private(set) internal var valuesDidChange = SnapshotValueChanged()


    // MARK: - Errors

    enum Error: Swift.Error {
        case flagKeyNotFound (String)
    }


    // MARK: - Source

    /// The source that we are to copy flag values from, if any
    enum Source {
        case pole
        case source(FlagValueSource)

        var flagValueSource: FlagValueSource? {
            switch self {
            case .pole:                     return nil
            case .source(let source):       return source
            }
        }
    }

}


#if !os(Linux)

typealias SnapshotValueChanged = PassthroughSubject<Void, Never>

#else

typealias SnapshotValueChanged = NotificationSink

struct NotificationSink {
    func send () {}
}

#endif
