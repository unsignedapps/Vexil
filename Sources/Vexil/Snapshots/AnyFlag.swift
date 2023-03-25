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

protocol AnyFlag {
    var key: String { get }

    func getFlagValue(in source: FlagValueSource?, diagnosticsEnabled: Bool) -> LocatedFlagValue?
    func save(to source: FlagValueSource) throws
}

extension Flag: AnyFlag {
    func getFlagValue(in source: FlagValueSource?, diagnosticsEnabled: Bool) -> LocatedFlagValue? {
        guard let result = value(in: source) else {
            return nil
        }
        return LocatedFlagValue(lookupResult: result, diagnosticsEnabled: diagnosticsEnabled)
    }

    func save(to source: FlagValueSource) throws {
        try source.setFlagValue(wrappedValue, key: key)
    }
}


// MARK: - Flag Groups

protocol AnyFlagGroup {
    func allFlags() -> [AnyFlag]
}

extension FlagGroup: AnyFlagGroup {
    func allFlags() -> [AnyFlag] {
        return Mirror(reflecting: wrappedValue)
            .children
            .lazy
            .map { $0.value }
            .allFlags()
    }
}

internal extension Sequence {
    func allFlags() -> [AnyFlag] {
        return compactMap { element -> [AnyFlag]? in
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
