//
//  FlagLookup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

/// An internal protocol that is provided to each `Flag` when it is decorated.
/// The `Flag.wrappedValue` then uses this protocol to lookup what the current
/// value of a flag is from the source hierarchy.
///
/// Only `FlagPole` and `Snapshot`s conform to this.
///
internal protocol Lookup: AnyObject {
    func lookup<Value> (key: String) -> Value? where Value: FlagValue
}

extension FlagPole: Lookup {

    /// This is the primary lookup function in a `FlagPole`. When you access the `Flag.wrappedValue`
    /// this lookup function is called.
    ///
    /// It iterates through our `FlagValueSource`s and asks each if they have a `FlagValue` for
    /// that key, returning the first non-nil value it finds.
    ///
    func lookup<Value> (key: String) -> Value? where Value: FlagValue {
        for source in self._sources {
            if let value: Value = source.flagValue(key: key) {
                return value
            }
        }
        return nil
    }
}
