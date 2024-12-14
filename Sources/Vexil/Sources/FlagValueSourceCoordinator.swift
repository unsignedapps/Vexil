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

    /// Create a FlagValueSource from a NonSendableFlagValueSource. If `Source` is a reference type,
    /// you must not continue to access it (except via this coordinator) after passing it to this
    /// initializer.
    public init(uncheckedSource source: Source) {
        self.source = .init(uncheckedState: source)
    }

#if swift(>=6)
    /// Create a FlagValueSource from a NonSendableFlagValueSource.
    public init(source: sending Source) {
        self.source = .init(uncheckedState: source)
    }
#endif

}


// MARK: - Flag Value Source Conformance

extension FlagValueSourceCoordinator: FlagValueSource {

    public var flagValueSourceID: String {
        source.withLock {
            $0.flagValueSourceID
        }
    }

    public var flagValueSourceName: String {
        source.withLock {
            $0.flagValueSourceName
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

    public func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> Source.ChangeStream {
        source.withLockUnchecked {
            $0.flagValueChanges(keyPathMapper: keyPathMapper)
        }
    }

}
