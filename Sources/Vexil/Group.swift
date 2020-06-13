//
//  FlagGroup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

@propertyWrapper
public struct FlagGroup<Group>: Decorated where Group: FlagContainer {


    public var description: String

    public var wrappedValue = Group()


    // MARK: - Initialisation

    public init (codingKeyStrategy: CodingKeyStrategy = .default, description: String) {
        self.codingKeyStrategy = codingKeyStrategy
        self.description = description
    }

    /// An internal initialiser used so we can create Snapshtos that are decoupled from everything
    internal init (groupType: Group.Type) {
        self.codingKeyStrategy = .default
        self.description = ""
    }


    // MARK: - Decoratod Conformance

    internal var decorator = Decorator()
    private let codingKeyStrategy: CodingKeyStrategy

    func decorate(lookup: Lookup, label: String, codingPath: [String]) {
        let codingKey = self.codingKeyStrategy.codingKey(label: label)
            ?? lookup.codingKey(label: label)

        let codingPath = codingPath + [ codingKey ].filter { $0.isEmpty == false }

        self.decorator.key = codingPath.joined(separator: lookup.configuration.separator)
        self.decorator.lookup = lookup

        Mirror(reflecting: self)
            .children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: lookup, label: $0.label, codingPath: codingPath)
            }
    }
}
