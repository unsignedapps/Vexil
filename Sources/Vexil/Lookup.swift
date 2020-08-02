//
//  FlagLookup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

internal protocol Lookup: AnyObject {
    func lookup<Value> (key: String) -> Value? where Value: FlagValue
}

extension FlagPole: Lookup {
    func lookup<Value> (key: String) -> Value? where Value: FlagValue {
        for source in self._sources {
            if let value: Value = source.flagValue(key: key) {
                return value
            }
        }
        return nil
    }
}
