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
public struct Snapshot<RootGroup>: FlagValueSource where RootGroup: FlagContainer {

    public let id = UUID()
    private var _rootGroup: MutableFlagGroup<RootGroup, RootGroup>

    internal init (flagPole: FlagPole<RootGroup>, copyCurrentFlagValues: Bool) {
        self._rootGroup = MutableFlagGroup<RootGroup, RootGroup> (
            flagGroup: FlagGroup(groupType: RootGroup.self),
            flagPole: flagPole,
            copyCurrentFlagValues: copyCurrentFlagValues,
            valueChanged: self.valuesDidChange
        )
    }


    // MARK: - Flag Management

    public subscript<Subgroup> (dynamicMember dynamicMember: KeyPath<RootGroup, Subgroup>) -> MutableFlagGroup<Subgroup, RootGroup> where Subgroup: FlagContainer {
        return self._rootGroup[dynamicMember: dynamicMember]
    }

    public subscript<Value> (dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value? where Value: FlagValue {
        get {
            return self._rootGroup[dynamicMember: dynamicMember]
        }
        set {
            self._rootGroup[dynamicMember: dynamicMember] = newValue
        }
    }

    internal func allFlags () -> [AnyMutableFlag] {
        return self._rootGroup.allFlags()
    }


    // MARK: - FlagValueSource Conformance

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        guard let flag = self._rootGroup.flag(key: key) as? MutableFlag<Value> else { return nil }
        return flag.value
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value : FlagValue {
        assertionFailure("Snapshots cannot be mutated by applying other snapshots")
    }


    // MARK: - Real Time Flag Changes

    var valuesDidChange = SnapshotValueChanged()

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
