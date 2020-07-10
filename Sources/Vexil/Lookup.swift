//
//  FlagLookup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

internal protocol Lookup: AnyObject {
    var _configuration: VexilConfiguration { get }

    func lookup<Value> (key: String) -> Value? where Value: FlagValue
    func codingKey (label: String) -> CodingKeyAction
}

extension FlagPole: Lookup {
    func lookup<Value> (key: String) -> Value? where Value: FlagValue {
        return self._sources
            .lazy
            .compactMap { $0.flagValue(key: key) }
            .first
    }

    func codingKey (label: String) -> CodingKeyAction {
        return self._configuration.codingPathStrategy.codingKey(label: label)
    }
}
