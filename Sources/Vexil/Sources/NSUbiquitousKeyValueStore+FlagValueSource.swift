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

#if !os(Linux) && !os(watchOS)

import AsyncAlgorithms
import Foundation

/// Provides support for using `NSUbiquitousKeyValueStore` as a `NonSendableFlagValueSource`
///
extension NSUbiquitousKeyValueStore: NonSendableFlagValueSource {

    /// A unique identifier for the flag value source.
    public var flagValueSourceID: String {
        flagValueSourceName
    }

    /// The name of the Flag Value Source
    public var flagValueSourceName: String {
        "NSUbiquitousKeyValueStore\(self == NSUbiquitousKeyValueStore.default ? ".default" : "")"
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

        set(value.boxedFlagValue.object, forKey: key)

        // all because we can't set a stored property
        NotificationCenter.default.post(name: Self.didChangeInternallyNotification, object: self)

    }

    private static let didChangeInternallyNotification = NSNotification.Name(rawValue: "NSUbiquitousKeyValueStore.didChangeExternallyNotification")

    public typealias ChangeStream = AsyncThrowingMapSequence<
        AsyncChain2Sequence<
            AsyncFilterSequence<NotificationCenter.Notifications>,
            AsyncFilterSequence<NotificationCenter.Notifications>
        >,
        FlagChange
    >

    public func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> ChangeStream {
        let this = ObjectIdentifier(self)
        return chain(
            NotificationCenter.default
                .notifications(named: Self.didChangeExternallyNotification, object: nil)
                .filter { $0.object.isIdentical(to: this) },
            NotificationCenter.default
                .notifications(named: Self.didChangeInternallyNotification, object: nil)
                .filter { $0.object.isIdentical(to: this) }
        )
        .map { _ in
            FlagChange.all
        }
    }

}

private extension Any? {
    func isIdentical(to object: ObjectIdentifier) -> Bool {
        guard let self = self as? AnyObject else {
            return false
        }
        return ObjectIdentifier(self) == object
    }
}

#endif
