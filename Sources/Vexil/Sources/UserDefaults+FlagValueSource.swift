//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if !os(Linux)

#if canImport(AppKit)
import AppKit
#endif

import AsyncAlgorithms
import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Provides support for using `UserDefaults` as a `FlagValueSource`
extension UserDefaults: NonSendableFlagValueSource {

    /// A unique identifier for the flag value source.
    public var flagValueSourceID: String {
        flagValueSourceName
    }

    /// The name of the Flag Value Source
    public var flagValueSourceName: String {
        "UserDefaults\(self == UserDefaults.standard ? ".standard" : "")"
    }

    /// Fetch values for the specified key
    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {

        guard
            let object = object(forKey: key),
            let boxed = BoxedFlagValue(object: object, typeHint: Value.self)
        else {
            return nil
        }

        return Value(boxedFlagValue: boxed)
    }

    /// Sets the value for the specified key
    public func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        guard let value else {
            removeObject(forKey: key)
            return
        }

        if value.boxedFlagValue.object == NSNull() {
            set(Data(), forKey: key)
        } else {
            set(value.boxedFlagValue.object, forKey: key)
        }

    }

#if os(watchOS)

    public typealias ChangeStream = AsyncMapSequence<AsyncFilterSequence<NotificationCenter.Notifications>, FlagChange>

    public func flagValueChanges(keyPathMapper: @escaping (String) -> FlagKeyPath) -> ChangeStream {
        let this = ObjectIdentifier(self)
        return NotificationCenter.default
            .notifications(named: UserDefaults.didChangeNotification)
            .filter { $0.object.isIdentical(to: this) }
            .map { _ in
                FlagChange.all
            }
    }

#elseif os(macOS)

    public typealias ChangeStream = AsyncMapSequence<
        AsyncChain2Sequence<
            AsyncFilterSequence<NotificationCenter.Notifications>,
            NotificationCenter.Notifications
        >,
        FlagChange
    >

    public func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> ChangeStream {
        let this = ObjectIdentifier(self)
        return chain(
            NotificationCenter.default
                .notifications(named: UserDefaults.didChangeNotification)
                .filter { $0.object.isIdentical(to: this) },

            // We use the raw value here because the class property is painfully @MainActor
            NotificationCenter.default.notifications(named: .init("NSApplicationDidBecomeActiveNotification"))
        )
        .map { _ in
            FlagChange.all
        }
    }

#elseif canImport(UIKit)

    public typealias ChangeStream = AsyncMapSequence<
        AsyncChain2Sequence<
            AsyncFilterSequence<NotificationCenter.Notifications>,
            NotificationCenter.Notifications
        >,
        FlagChange
    >

    public func flagValueChanges(keyPathMapper: @escaping (String) -> FlagKeyPath) -> ChangeStream {
        let this = ObjectIdentifier(self)
        return chain(
            NotificationCenter.default
                .notifications(named: UserDefaults.didChangeNotification)
                .filter { $0.object.isIdentical(to: this) },

            // We use the raw value here because the class property is painfully @MainActor
            NotificationCenter.default.notifications(named: .init("UIApplicationDidBecomeActiveNotification"))
        )
        .map { _ in
            FlagChange.all
        }
    }

#else

    /// No support for real-time flag publishing with `UserDefaults` on Linux
    public func flagValueChanges(keyPathMapper: @escaping (String) -> FlagKeyPath) -> EmptyFlagChangeStream {
        .init()
    }

#endif
}

private extension Any? {
    func isIdentical(to object: ObjectIdentifier) -> Bool {
        guard let self = self as? AnyObject else {
            return false
        }
        return ObjectIdentifier(self) == object
    }
}

#endif // !os(Linux)
