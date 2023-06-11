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

#if !os(Linux) && !os(watchOS)

import Combine
import Foundation

/// Provides support for using `NSUbiquitousKeyValueStore` as a `FlagValueSource`
///
extension NSUbiquitousKeyValueStore: FlagValueSource {

    /// The name of the Flag Value Source
    public var name: String {
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

    /// A Publisher that emits events when the flag values it manages changes
    public func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: Self.didChangeExternallyNotification, object: self).map { _ in () },
            NotificationCenter.default.publisher(for: Self.didChangeInternallyNotification, object: self).map { _ in () }
        )
        .map { _ in
            self.synchronize()
            return []
        }
        .eraseToAnyPublisher()
    }

}

#endif
