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

#if !os(Linux)
import Combine
#endif

import Foundation

/// Provides support for using `UserDefaults` as a `FlagValueSource`
extension UserDefaults: NonSendableFlagValueSource {

    /// The name of the Flag Value Source
    public var name: String {
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

        set(value.boxedFlagValue.object, forKey: key)

    }

    public var changeStream: EmptyFlagChangeStream {
        .init()
    }

#if os(watchOS)

    /// A Publisher that emits events when the flag values it manages changes
    public func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .filter { ($0.object as AnyObject) === self }
            .map { _ in [] }
            .eraseToAnyPublisher()
    }

#elseif !os(Linux)

    public func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
                .filter { ($0.object as AnyObject) === self }
                .map { _ in () },
            NotificationCenter.default.publisher(for: ApplicationDidBecomeActive).map { _ in () }
        )
        .map { _ in [] }
        .eraseToAnyPublisher()
    }

#endif
}


// MARK: - Application Active Notifications

#if canImport(UIKit) && !os(watchOS)

import UIKit

@MainActor
private let ApplicationDidBecomeActive = UIApplication.didBecomeActiveNotification

#elseif canImport(Cocoa)

import Cocoa

@MainActor
private let ApplicationDidBecomeActive = NSApplication.didBecomeActiveNotification

#endif
