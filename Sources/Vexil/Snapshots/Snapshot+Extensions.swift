//
//  Snapshot+Extensions.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

extension Snapshot: Identifiable {}

extension Snapshot: Equatable where RootGroup: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        return lhs._rootGroup == rhs._rootGroup
    }
}

extension Snapshot: Hashable where RootGroup: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self._rootGroup)
    }
}
