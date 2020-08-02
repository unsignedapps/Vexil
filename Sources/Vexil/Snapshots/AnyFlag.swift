//
//  AnyFlag.swift
//  Vexil
//
//  Created by Rob Amos on 2/8/20.
//

protocol AnyFlag {
    var key: String { get }

    func getFlagValue () -> Any
    func save (to source: FlagValueSource) throws
}

protocol AnyFlagGroup {
    func allFlags () -> [AnyFlag]
}

extension Flag: AnyFlag {
    func getFlagValue() -> Any {
        return self.wrappedValue
    }

    func save(to source: FlagValueSource) throws {
        try source.setFlagValue(self.wrappedValue, key: self.key)
    }
}


extension FlagGroup: AnyFlagGroup {
    func allFlags () -> [AnyFlag] {
        return Mirror(reflecting: self.wrappedValue)
            .children
            .lazy
            .map { $0.value }
            .allFlags()
    }
}

internal extension Sequence {
    func allFlags () -> [AnyFlag] {
        return self
            .compactMap { element -> [AnyFlag]? in
                if let flag = element as? AnyFlag {
                    return [flag]
                } else if let group = element as? AnyFlagGroup {
                    return group.allFlags()
                } else {
                    return nil
                }
            }
            .flatMap { $0 }
    }
}
