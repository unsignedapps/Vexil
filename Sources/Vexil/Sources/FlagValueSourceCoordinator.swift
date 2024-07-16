//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

/// A coordinating wrapper that provides synchronised access to
/// ``NonSendableFlagValueSource`` types like `UserDefaults`.
///
/// - Note: If your flag value source is `Sendable` you should conform directly
/// to ``FlagValueSource`` and skip this coordinator.
///
public final class FlagValueSourceCoordinator<Source>: Sendable where Source: NonSendableFlagValueSource {

    // MARK: - Properties

    // Private but for @testable
    let source: Lock<Source>


    // MARK: - Initialisation

    public init(source: Source) {
        self.source = .init(uncheckedState: source)
    }

}


// MARK: - Flag Value Source Conformance

extension FlagValueSourceCoordinator: FlagValueSource {

    public var flagValueSourceID: String {
        source.withLock {
            $0.flagValueSourceID
        }
    }

    public var name: String {
        source.withLock {
            $0.name
        }
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        source.withLock {
            $0.flagValue(key: key)
        }
    }

    public func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        try source.withLock {
            try $0.setFlagValue(value, key: key)
        }
    }

    public var changes: Source.ChangeStream {
        source.withLockUnchecked {
            $0.changes
        }
    }

}
