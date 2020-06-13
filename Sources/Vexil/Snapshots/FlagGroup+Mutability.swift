//
//  FlagGroup+MutabilityExtensions.swift
//  Vexil
//
//  Created by Rob Amos on 13/6/20.
//

import Foundation

internal extension FlagGroup {
    func mutableSubgroups<Root> (flagPole: FlagPole<Root>, copyCurrentFlagValues: Bool, valueChanged: SnapshotValueChanged) -> [PartialKeyPath<Group>: AnyMutableFlagGroup] where Root: FlagContainer {
        var flagGroups = [PartialKeyPath<Group>: AnyMutableFlagGroup]()
        let mirror = Mirror(reflecting: self.wrappedValue)
        for case (let key?, let value) in mirror.children {
            guard let factory = value as? MutableFlagGroupFactory else { continue }
            let keyPath = \Group.[checkedMirrorDescendant: key] as PartialKeyPath
            flagGroups[keyPath] = factory.makeMutableFlagGroup(flagPole: flagPole, copyCurrentFlagValues: copyCurrentFlagValues, valueChanged: valueChanged)
        }
        return flagGroups
    }
}


// MARK: - Creating Mutable Flag Groups

fileprivate protocol MutableFlagGroupFactory {
    func makeMutableFlagGroup<Root> (flagPole: FlagPole<Root>, copyCurrentFlagValues: Bool, valueChanged: SnapshotValueChanged) -> AnyMutableFlagGroup
}

extension FlagGroup: MutableFlagGroupFactory {
    func makeMutableFlagGroup<Root>(flagPole: FlagPole<Root>, copyCurrentFlagValues: Bool, valueChanged: SnapshotValueChanged) -> AnyMutableFlagGroup where Root: FlagContainer {
        return MutableFlagGroup(flagGroup: self, flagPole: flagPole, copyCurrentFlagValues: copyCurrentFlagValues, valueChanged: valueChanged)
    }
}


// MARK: - Type Erasing Mutable Flag Groups


internal protocol AnyMutableFlagGroup {
    func allFlags () -> [AnyMutableFlag]
    func flag (key: String) -> AnyMutableFlag?
}
extension MutableFlagGroup: AnyMutableFlagGroup {}
