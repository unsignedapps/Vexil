//
//  File.swift
//  
//
//  Created by Rob Amos on 13/6/20.
//

import Foundation

internal extension FlagGroup {
    func mutableFlags (copyCurrentFlagValues: Bool, valueChanged: SnapshotValueChanged) -> [PartialKeyPath<Group>: AnyMutableFlag] {
        var flags = [PartialKeyPath<Group>: AnyMutableFlag]()
        let mirror = Mirror(reflecting: self.wrappedValue)
        for case (let key?, let value) in mirror.children {
            guard let factory = value as? MutableFlagFactory else { continue }
            let keyPath = \Group.[checkedMirrorDescendant: key] as PartialKeyPath
            flags[keyPath] = factory.makeMutableFlag(copyCurrentFlagValue: copyCurrentFlagValues, valueChanged: valueChanged)
        }
        return flags
    }
}


// MARK: - Creating Mutable Flags

private protocol MutableFlagFactory {
    func makeMutableFlag (copyCurrentFlagValue: Bool, valueChanged: SnapshotValueChanged) -> AnyMutableFlag
}

extension Flag: MutableFlagFactory {
    func makeMutableFlag (copyCurrentFlagValue: Bool, valueChanged: SnapshotValueChanged) -> AnyMutableFlag {
        return MutableFlag(flag: self, value: copyCurrentFlagValue ? self.wrappedValue : nil, valueChanged: valueChanged)
    }
}


// MARK: - Type Erasing Mutable Flags

internal protocol AnyMutableFlag {
    var key: String { get }
    var isDirty: Bool { get }

    func save (to source: FlagValueSource) throws
}

extension MutableFlag: AnyMutableFlag {
    var key: String {
        self.flag.key
    }
}
