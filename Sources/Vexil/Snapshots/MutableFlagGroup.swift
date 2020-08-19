//
//  Group+Mutability.swift
//  Vexil
//
//  Created by Rob Amos on 31/5/20.
//

import Foundation

/// A `MutableFlagGroup` is a wrapper type that provides a "setter" for each contained `Flag`. 
@dynamicMemberLookup
public class MutableFlagGroup<Group, Root> where Group: FlagContainer, Root: FlagContainer {


    // MARK: - Properties

    private var group: Group
    weak private var snapshot: Snapshot<Root>?


    // MARK: - Dynamic Member Lookup

    /// A @dynamicMemberLookup implementation for subgroups
    ///
    /// Returns a `MutableFlagGroup` for the Subgroup at the specified KeyPath.
    ///
    /// ```swift
    /// flagPole.mySubgroup.mySecondSubgroup    // -> FlagGroup<MySecondSubgroup>
    /// snapshot.mySubgroup.mySecondSubgroup    // -> MutableFlagGroup<MySecondSubgroup>
    /// ```
    ///
    public subscript<Subgroup> (dynamicMember dynamicMember: KeyPath<Group, Subgroup>) -> MutableFlagGroup<Subgroup, Root> where Subgroup: FlagContainer {
        let group = self.group[keyPath: dynamicMember]
        return MutableFlagGroup<Subgroup, Root>(group: group, snapshot: self.snapshot)
    }

    /// A @dynamicMemberLookup implementation for FlagValues used solely to provide a `setter`.
    ///
    /// Takes a lock on the Snapshot to read and write values to it.
    ///
    /// ```swift
    /// flagPole.mySubgroup.myFlag = true       // Error: FlagPole is not mutable
    /// snapshot.mySubgroup.myFlag = true       // 👍
    /// ```
    ///
    public subscript<Value> (dynamicMember dynamicMember: KeyPath<Group, Value>) -> Value where Value: FlagValue {
        get {
            guard let snapshot = self.snapshot else { return self.group[keyPath: dynamicMember] }

            return snapshot.lock.withLock {
                self.group[keyPath: dynamicMember]
            }
        }
        set {
            guard let snapshot = self.snapshot else { return }

            // see Snapshot.swift for how terrible this is
            return snapshot.lock.withLock {
                _ = self.group[keyPath: dynamicMember]
                guard let key = snapshot.lastAccessedKey else { return }
                snapshot.set(newValue, key: key)
            }
        }
    }

    /// Internal initialiser used to create MutableFlagGroups for a given subgroup and snapshot
    ///
    init (group: Group, snapshot: Snapshot<Root>?) {
        self.group = group
        self.snapshot = snapshot
    }

}
