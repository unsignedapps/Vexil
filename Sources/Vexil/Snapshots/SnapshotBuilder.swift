//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

extension Snapshot {

    final class Builder {

        // MARK: - Properties

        private let flagPole: FlagPole<RootGroup>?
        private let source: (any FlagValueSource)?

        private let rootKeyPath: FlagKeyPath
        private let keys: Set<String>?

        private var flags: [String: LocatedFlag] = [:]


        // MARK: - Initialisation

        init(flagPole: FlagPole<RootGroup>?, source: (any FlagValueSource)?, rootKeyPath: FlagKeyPath, keys: Set<String>?) {
            self.flagPole = flagPole
            self.source = source
            self.rootKeyPath = rootKeyPath
            self.keys = keys
        }


        // MARK: - Building

        func build() -> [String: LocatedFlag] {
            let hierarchy = RootGroup(_flagKeyPath: rootKeyPath, _flagLookup: self)
            hierarchy.walk(visitor: self)
            return flags
        }

    }

}


// MARK: - Flag Lookup

extension Snapshot.Builder: FlagLookup {

    /// Provides lookup capabilities to the flag hierarchy for our visit.
    func locate<Value>(keyPath: FlagKeyPath, of valueType: Value.Type) -> (value: Value, sourceName: String)? where Value: FlagValue {
        if let flagPole {
            return flagPole.locate(keyPath: keyPath, of: valueType)

        } else if let source, let value: Value = source.flagValue(key: keyPath.key) {
            return (value, source.name)

        } else {
            return nil
        }
    }

    // Not used while walking the flag hierarchy
    func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue {
        nil
    }

    // Not used while walking the flag hierarchy
    func value<Value>(for keyPath: FlagKeyPath, in source: FlagValueSource) -> Value? where Value: FlagValue {
        nil
    }

}


// MARK: - Flag Visitor

extension Snapshot.Builder: FlagVisitor {

    func visitFlag(keyPath: FlagKeyPath, value: some Any, sourceName: String?) {
        let key = keyPath.key
        guard keys == nil || keys?.contains(key) == true else {
            return
        }

        // if we are copying from a specific source but we got the default back exclude it
        if source != nil, sourceName == nil {
            return
        }

        flags[key] = (value, sourceName)
    }

}
