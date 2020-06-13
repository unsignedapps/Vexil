//
//  Group+Mutability.swift
//  Vexil
//
//  Created by Rob Amos on 31/5/20.
//

import Foundation

@dynamicMemberLookup
public class MutableFlagGroup<Group, Root> where Group: FlagContainer, Root: FlagContainer {


    // MARK: - Properties

    private var flagGroup: FlagGroup<Group>

    /// A collection of `MutableFlagGroup`s for the KeyPath to the original sub-group on `Group`
    ///
    /// eg. if you have `Group.subGroup = SubGroup()`, then this would be:
    ///
    /// ```
    ///     self.mutableGroups = [
    ///         KeyPath<Group, SubGroup>: MutableFlagGroup<SubGroup, Root>
    ///     ]
    /// ```
    ///
    private var mutableGroups: [PartialKeyPath<Group>: AnyMutableFlagGroup]

    /// A collection of `MutableFlag`s that exist as direct properties on `Group`.
    /// It maps the KeyPaths used to access the _value_ of the flag to a mutable copy of the Flag.
    ///
    /// eg. If you have `Group.myFlag = Flag<Bool>` then this would be:
    ///
    /// ```
    ///     self.mutableFlags = [
    ///         KeyPath<Group, Bool>: MutableFlag<Bool>
    ///     ]
    /// ```
    private var mutableFlags: [PartialKeyPath<Group>: AnyMutableFlag]



    // MARK: - Dynamic Member Lookup

    // swiftlint:disable force_cast

    public subscript<G> (dynamicMember dynamicMember: KeyPath<Group, G>) -> MutableFlagGroup<G, Root> where G: FlagContainer {
        return self.mutableGroups[dynamicMember] as! MutableFlagGroup<G, Root>
    }

    public subscript<Value> (dynamicMember dynamicMember: KeyPath<Group, Value>) -> Value? where Value: FlagValue {
        get {
            return (self.mutableFlags[dynamicMember] as! MutableFlag<Value>).value
        }
        set {
            (self.mutableFlags[dynamicMember] as! MutableFlag<Value>).value = newValue
        }
    }

    // swiftlint:enable force_cast

    init (flagGroup: FlagGroup<Group>, flagPole: FlagPole<Root>, copyCurrentFlagValues: Bool, valueChanged: SnapshotValueChanged) {
        self.flagGroup = flagGroup

        // iterate over the subgroups on Group
        self.mutableGroups = flagGroup.mutableSubgroups(flagPole: flagPole, copyCurrentFlagValues: copyCurrentFlagValues, valueChanged: valueChanged)

        // find our groups
        self.mutableFlags = flagGroup.mutableFlags(copyCurrentFlagValues: copyCurrentFlagValues, valueChanged: valueChanged)
    }


    // MARK: - All Flags

    func allFlags () -> [AnyMutableFlag] {
        return self.mutableGroups.values.flatMap({ $0.allFlags() })
            + self.mutableFlags.values
    }

    func flag (key: String) -> AnyMutableFlag? {
        if let flag = self.mutableFlags.values.first(where: { $0.key == key }) {
            return flag
        }

        return self.mutableGroups
            .lazy
            .compactMap { $0.value.flag(key: key) }
            .first
    }
}
