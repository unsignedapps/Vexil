//
//  Flag.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

@propertyWrapper
public struct Flag<Value>: Decorated, Identifiable where Value: FlagValue {

    // MARK: - Properties

    public var id = UUID()
    public var description: String
    public var defaultValue: Value

    public var wrappedValue: Value {
        guard let lookup = self.decorator.lookup, let key = self.decorator.key else { return self.defaultValue }
        return lookup.lookup(key: key) ?? self.defaultValue
    }

    public var key: String {
        return self.decorator.key!
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

        var action = self.codingKeyStrategy.codingKey(label: label)
        if action == .default {
            action = lookup.codingKey(label: label)
        }

        switch action {

        case .append(let string):
            self.decorator.key = (codingPath + [string])
                .joined(separator: lookup._configuration.separator)

        case .absolute(let string):
            self.decorator.key = string

        // these two options should really never happen, but just in case, use what we've got
        case .default, .skip:
            assertionFailure("Invalid `CodingKeyAction` found when attempting to create key name for Flag \(self)")
            self.decorator.key = (codingPath + [label])
                .joined(separator: lookup._configuration.separator)

        }
    }
}
