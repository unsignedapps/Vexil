//
//  Flag.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

@propertyWrapper
public struct Flag<Value>: Decorated where Value: FlagValue {

    // MARK: - Properties

    public var description: String
    public var defaultValue: Value

    public var wrappedValue: Value {
        guard let lookup = self.decorator.lookup, let key = self.decorator.key else { return self.defaultValue }
        return lookup.lookup(key: key) ?? self.defaultValue
    }


    // MARK: - Initialisation

    public init (codingKeyStrategy: CodingKeyStrategy = .default, default initialValue: Value, description: String) {
        self.codingKeyStrategy = codingKeyStrategy
        self.description = description
        self.defaultValue = initialValue
    }


    // MARK: - Decorated Conformance

    internal var decorator = Decorator()
    internal let codingKeyStrategy: CodingKeyStrategy

    internal func decorate (lookup: Lookup, label: String, codingPath: [String]) {
        self.decorator.lookup = lookup

        let codingKey = self.codingKeyStrategy.codingKey(label: label)
            ?? lookup.codingKey(label: label)
        self.decorator.key = (codingPath + [codingKey])
            .joined(separator: lookup._configuration.separator)
    }
}
