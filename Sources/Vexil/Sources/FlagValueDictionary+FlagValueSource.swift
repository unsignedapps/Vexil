//
//  FlagValueDictionary+FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

#if !os(Linux)
import Combine
#endif

extension FlagValueDictionary: FlagValueSource {

    public var name: String {
        return "\(String(describing: Self.self)): \(self.id.uuidString)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        guard let value = self.storage[key] else {
            return nil
        }
        return Value(boxedFlagValue: value)
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        if let value = value {
            self.storage.updateValue(value.boxedFlagValue, forKey: key)
        } else {
            self.storage.removeValue(forKey: key)
        }

#if !os(Linux)
        self.valueDidChange.send([ key ])
#endif

    }

#if !os(Linux)

    public func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        self.valueDidChange
            .eraseToAnyPublisher()
    }

#endif
}
