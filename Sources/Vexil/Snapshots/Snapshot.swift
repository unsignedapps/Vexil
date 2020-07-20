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

@dynamicMemberLookup
public class Snapshot<RootGroup>: FlagValueSource where RootGroup: FlagContainer {

    public let id = UUID()
    private var _rootGroup: RootGroup
    private var values: [String: Any] = [:]

    internal var lock = Lock()

    internal var lastAccessedKey: String?

    internal init (flagPole: FlagPole<RootGroup>, copyCurrentFlagValues: Bool) {
        self._rootGroup = RootGroup.init()
        self.decorateRootGroup(config: flagPole._configuration)

        if copyCurrentFlagValues {
            self.copyCurrentValues(flagPole: flagPole)
        }
    }

//    internal init (group: RootGroup) {
//        self._rootGroup = group
//    }


    // MARK: - Flag Management

    public subscript<Subgroup> (dynamicMember dynamicMember: KeyPath<RootGroup, Subgroup>) -> MutableFlagGroup<Subgroup, RootGroup> where Subgroup: FlagContainer {
        let group = self._rootGroup[keyPath: dynamicMember]
        return MutableFlagGroup<Subgroup, RootGroup>(group: group, snapshot: self)
    }

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
                let _ = self._rootGroup[keyPath: dynamicMember]

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

        self.allFlags = children.lazy.allFlags()
    }

    private func copyCurrentValues (flagPole: FlagPole<RootGroup>) {
        let flags = Mirror(reflecting: flagPole._rootGroup)
            .children
            .lazy
            .map { $0.value }
            .allFlags()
            .map { ($0.key, $0.getFlagValue()) }

        self.values = Dictionary(uniqueKeysWithValues: flags)
    }

    internal func changedFlags () -> [AnyFlag] {
        guard self.values.isEmpty == false else { return [] }

        let changed = self.values.keys
        return self.allFlags
            .filter { changed.contains($0.key) }
    }


    // MARK: - FlagValueSource Conformance

    public var name: String {
        return "Snapshot \(self.id.uuidString)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.values[key] as? Value
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        self.set(value, key: key)
    }

    internal func set (_ value: Any?, key: String) {
        if let value = value {
            self.values[key] = value
        } else {
            self.values.removeValue(forKey: key)
        }

        self.valuesDidChange.send()
    }


    // MARK: - Real Time Flag Changes

    var valuesDidChange = SnapshotValueChanged()


    // MARK: - Errors

    enum Error: Swift.Error {
        case flagKeyNotFound (String)
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


// MARK: - Identifiable and Equatable Conformance

extension Snapshot: Identifiable {}

extension Snapshot: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - Snapshot Lookup

extension Snapshot: Lookup {
    func lookup<Value>(key: String) -> Value? where Value: FlagValue {
        self.lastAccessedKey = key
        return self.values[key] as? Value
    }
}

protocol AnyFlag {
    var key: String { get }

    func getFlagValue () -> Any
    func save (to source: FlagValueSource) throws
}

protocol AnyFlagGroup {
    func allFlags () -> [AnyFlag]
}

extension Flag: AnyFlag {
    func getFlagValue() -> Any {
        return self.wrappedValue
    }

    func save(to source: FlagValueSource) throws {
        try source.setFlagValue(self.wrappedValue, key: self.key)
    }
}


extension FlagGroup: AnyFlagGroup {
    func allFlags () -> [AnyFlag] {
        return Mirror(reflecting: self.wrappedValue)
            .children
            .lazy
            .map { $0.value }
            .allFlags()
    }
}

internal extension Sequence {
    func allFlags () -> [AnyFlag] {
        return self
            .compactMap { element -> [AnyFlag]? in
                if let flag = element as? AnyFlag {
                    return [flag]
                } else if let group = element as? AnyFlagGroup {
                    return group.allFlags()
                } else {
                    return nil
                }
            }
            .flatMap { $0 }
    }
}
