//
//  Snapshot+Extensions.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

extension Snapshot: Identifiable {}

extension Snapshot: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        return lhs.id == rhs.id
    }
}
