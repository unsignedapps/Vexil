//
//  FlagGroup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

@propertyWrapper
public struct FlagGroup<Group>: Decorated, Identifiable where Group: FlagContainer {

    public let id = UUID()
    public let info: FlagInfo

    public var wrappedValue: Group


    // MARK: - Initialisation

    public init (name: String? = nil, codingKeyStrategy: CodingKeyStrategy = .default, description: FlagInfo) {
        self.codingKeyStrategy = codingKeyStrategy
        self.wrappedValue = Group()

        var info = description
        info.name = name
        self.info = info
    }

    /// An internal initialiser used so we can create Snapshtos that are decoupled from everything
    internal init (group: Group) {
        self.codingKeyStrategy = .default
        self.wrappedValue = group
        self.info = .hidden
    }


    // MARK: - Decoratod Conformance

    internal var decorator = Decorator()
    private let codingKeyStrategy: CodingKeyStrategy

    func decorate(lookup: Lookup, label: String, codingPath: [String], config: VexilConfiguration) {
        var action = self.codingKeyStrategy.codingKey(label: label)
        if action == .default {
            action = config.codingPathStrategy.codingKey(label: label)
        }

        var codingPath = codingPath

        switch action {
        case .append(let string):
            codingPath.append(string)

        case .skip:
            break

        // these actions shouldn't be possible in theory
        case .absolute, .default:
            assertionFailure("Invalid `CodingKeyAction` found when attempting to create key name for FlagGroup \(self)")

        }

        self.decorator.key = codingPath.joined(separator: config.separator)
        self.decorator.lookup = lookup

        Mirror(reflecting: self.wrappedValue)
            .children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: lookup, label: $0.label, codingPath: codingPath, config: config)
            }
    }
}
