//
//  Decorator.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

import Foundation

internal protocol Decorated {
    func decorate (lookup: Lookup, label: String, codingPath: [String])
}

internal class Decorator {
    var key: String?
    weak var lookup: Lookup?

    init() {}
}

internal extension Sequence where Element == Mirror.Child {

    typealias DecoratedChild = (label: String, value: Decorated)

    var decorated: [DecoratedChild] {
        return self
            .compactMap { child -> DecoratedChild? in
                guard
                    let label = child.label,
                    let value = child.value as? Decorated
                else {
                        return nil
                }

                return (label, value)
            }

            // all of our decorated items are property wrappers,
            // so they'll start with an underscore
            .map { child -> DecoratedChild in
                (
                    label: child.label.hasPrefix("_") ? String(child.label.dropFirst()) : child.label,
                    value: child.value
                )
            }
    }
}
