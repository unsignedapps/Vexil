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

import Foundation

/// A diagnostic that is returned by `FlagPole.makeDiagnostics()`
///
public enum FlagPoleDiagnostic: Equatable {

    // MARK: - Cases

    case currentValue(key: String, value: BoxedFlagValue, resolvedBy: String?)
    case changedValue(key: String, value: BoxedFlagValue, resolvedBy: String?, changedBy: String?)

}


// MARK: - Initialisation

extension [FlagPoleDiagnostic] {

    /// Creates diagnostic cases from an initial snapshot
    init(current: Snapshot<some FlagContainer>) {
        self = current.values
            .sorted(by: { $0.key < $1.key })
            .compactMap { element -> FlagPoleDiagnostic? in
                guard let value = element.value.boxed else {
                    return nil
                }
                return .currentValue(key: element.key, value: value, resolvedBy: element.value.source)
            }

    }

    /// Creates diagnostic cases from a changed snapshot
    init(changed: Snapshot<some FlagContainer>, sources: [String]?) {
        guard let sources else {
            self = .init(current: changed)
            return
        }
        let changedBy = Set(sources).sorted().joined(separator: ", ")

        self = changed.values
            .sorted(by: { $0.key < $1.key })
            .compactMap { element -> FlagPoleDiagnostic? in
                guard let value = element.value.boxed else {
                    return nil
                }
                return .changedValue(key: element.key, value: value, resolvedBy: element.value.source, changedBy: changedBy)
            }

    }

}


// MARK: - Debugging

extension FlagPoleDiagnostic: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case let .currentValue(key: key, value: value, resolvedBy: source):
            return "Current value of flag '\(key)' is '\(String(describing: value))'. Resolved by: \(source ?? "Default value")"
        case let .changedValue(key: key, value: value, resolvedBy: source, changedBy: trigger):
            return "Value of flag '\(key)' was changed to '\(String(describing: value))' by '\(trigger ?? "an unknown source")'. Resolved by: \(source ?? "Default value")"
        }
    }

}


// MARK: - Errors

public extension FlagPoleDiagnostic {

    enum Error: LocalizedError {
        case notEnabledForSnapshot

        public var errorDescription: String? {
            switch self {
            case .notEnabledForSnapshot:
                "This snapshot was not taken with diagnostics enabled. Take it again using `FlagPole.snapshot(enableDiagnostics: true)`"
            }
        }
    }

}
