//
//  NSUbiquitousKeyValueStore+FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 9/9/20.
//

#if !os(Linux) && !os(watchOS)

import Combine
import Foundation

/// Provides support for using `NSUbiquitousKeyValueStore` as a `FlagValueSource`
///
extension NSUbiquitousKeyValueStore: FlagValueSource {

    public var name: String {
        return "NSUbiquitousKeyValueStore\(self == NSUbiquitousKeyValueStore.default ? ".default" : "")"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {

        guard
            let object = self.object(forKey: key),
            let boxed = BoxedFlagValue(object: object, typeHint: Value.self)
        else { return nil }

        return Value(boxedFlagValue: boxed)
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        guard let value = value else {
            self.removeObject(forKey: key)
            return
        }

        self.set(value.boxedFlagValue.object, forKey: key)

        // all because we can't set a stored property
        NotificationCenter.default.post(name: Self.didChangeInternallyNotification, object: self)

    }

    private static let didChangeInternallyNotification = NSNotification.Name(rawValue: "NSUbiquitousKeyValueStore.didChangeExternallyNotification")

    public var valuesDidChange: AnyPublisher<Void, Never>? {
        return Publishers.Merge(
                NotificationCenter.default.publisher(for: Self.didChangeExternallyNotification, object: self).map { _ in () },
                NotificationCenter.default.publisher(for: Self.didChangeInternallyNotification, object: self).map { _ in () }
            )
            .map { _ in
                self.synchronize()
                return ()
            }
            .eraseToAnyPublisher()
    }

}

#endif
