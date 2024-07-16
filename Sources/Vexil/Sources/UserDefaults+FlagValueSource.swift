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

    public typealias ChangeStream = AsyncMapSequence<NotificationCenter.Notifications, FlagChange>

    public var flagValueChanges: ChangeStream {
        NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification, object: self)
            .map { _ in
                FlagChange.all
            }
    }

#elseif os(macOS)

    public typealias ChangeStream = AsyncMapSequence<AsyncChain2Sequence<NotificationCenter.Notifications, NotificationCenter.Notifications>, FlagChange>

    public var flagValueChanges: ChangeStream {
        chain(
            NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification, object: self),

            // We use the raw value here because the class property is painfully @MainActor
            NotificationCenter.default.notifications(named: .init("NSApplicationDidBecomeActiveNotification"))
        )
        .map { _ in
            FlagChange.all
        }
    }

#elseif canImport(UIKit)

    public typealias ChangeStream = AsyncMapSequence<AsyncChain2Sequence<NotificationCenter.Notifications, NotificationCenter.Notifications>, FlagChange>

    public var flagValueChanges: ChangeStream {
        chain(
            NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification, object: self),

            // We use the raw value here because the class property is painfully @MainActor
            NotificationCenter.default.notifications(named: .init("UIApplicationDidBecomeActiveNotification"))
        )
        .map { _ in
            FlagChange.all
        }
    }

#else

    /// No support for real-time flag publishing with `UserDefaults` on Linux
    public var flagValueChanges: EmptyFlagChangeStream {
        .init()
    }

#endif
}
