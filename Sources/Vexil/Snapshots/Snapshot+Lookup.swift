//
//  Snapshot+Lookup.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

#if !os(Linux)
import Combine
#endif

extension Snapshot: Lookup {
    func lookup<Value>(key: String, in source: FlagValueSource?) -> Value? where Value: FlagValue {
        self.lastAccessedKey = key
        return self.values[key] as? Value
    }

    #if !os(Linux)

    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue {
        self.valuesDidChange
            .compactMap { [weak self] _ in
                self?.values[key] as? Value
            }
            .eraseToAnyPublisher()
    }

    #endif
}
