//
//  Snapshot.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

import Combine
import Foundation

@dynamicMemberLookup
public struct Snapshot<RootGroup> where RootGroup: FlagContainer {

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

    internal func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        guard let flag = self._rootGroup.flag(key: key) as? MutableFlag<Value> else { return nil }
        return flag.value
    }

    internal func allFlags () -> [AnyMutableFlag] {
        return self._rootGroup.allFlags()
    }


    // MARK: - Real Time Flag Changes

    var valuesDidChange = PassthroughSubject<Void, Never>()
}

typealias SnapshotValueChanged = PassthroughSubject<Void, Never>


// MARK: - Identifiable and Equatable Conformance

extension Snapshot: Identifiable {}

extension Snapshot: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        return lhs.id == rhs.id
    }
}
