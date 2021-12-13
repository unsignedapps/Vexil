//
//  Snapshot+FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

extension Snapshot: FlagValueSource {
    public var name: String {
        return self.displayName ?? "Snapshot \(self.id.uuidString)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.values[key]?.value as? Value
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        self.set(value, key: key)
    }
}
