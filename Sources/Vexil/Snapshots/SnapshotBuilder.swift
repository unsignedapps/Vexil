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

        private var flags: [String: any FlagValue] = [:]


        // MARK: - Initialisation

        init(flagPole: FlagPole<RootGroup>?, source: (any FlagValueSource)?, rootKeyPath: FlagKeyPath, keys: Set<String>?) {
            self.flagPole = flagPole
            self.source = source
            self.rootKeyPath = rootKeyPath
            self.keys = keys
        }


        // MARK: - Building

        func build() -> [String: any FlagValue] {
            let hierarchy = RootGroup(_flagKeyPath: rootKeyPath, _flagLookup: self)
            hierarchy.walk(visitor: self)
            return flags
        }

    }

}


// MARK: - Flag Lookup

extension Snapshot.Builder: FlagLookup {

    /// Provides lookup capabilities to the flag hierarchy for our visit.
    func value<Value>(for keyPath: FlagKeyPath) -> Value? where Value: FlagValue {
        if let flagPole {
            return flagPole.value(for: keyPath)

        } else if let source, let value: Value = source.flagValue(key: keyPath.key) {
            return value

        } else {
            return nil
        }
    }

    // Not used while walking the flag hierarchy
    func value<Value>(for keyPath: FlagKeyPath, in source: any FlagValueSource) -> Value? where Value: FlagValue {
        nil
    }

    var changeStream: FlagChangeStream {
        AsyncStream {
            $0.finish()
        }
    }

}


// MARK: - Flag Visitor

extension Snapshot.Builder: FlagVisitor {

    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue {
        let key = keyPath.key
        guard keys == nil || keys?.contains(key) == true, let value = value() else {
            return
        }

        flags[key] = value
    }

}
