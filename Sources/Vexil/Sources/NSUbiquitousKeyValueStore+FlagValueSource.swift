//
//  NSUbiquitousKeyValueStore+FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 9/9/20.
//

#if !os(Linux)
import Combine
#endif

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

    #if !os(Linux)

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

    #endif
}


// MARK: - Unboxing

private extension BoxedFlagValue {
    init?<Value> (object: Any, typeHint: Value.Type) {
        switch object {
        case let value as Bool where typeHint == Bool.self:
            self = .bool(value)

        case let value as Data:             self = .data(value)
        case let value as Int:              self = .integer(value)
        case let value as Float:            self = .float(value)
        case let value as Double:           self = .double(value)
        case let value as String:           self = .string(value)
        case is NSNull:                     self = .none

        case let value as [Any]:            self = .array(value.compactMap({ BoxedFlagValue(object: $0, typeHint: typeHint) }))
        case let value as [String: Any]:    self = .dictionary(value.compactMapValues({ BoxedFlagValue(object: $0, typeHint: typeHint) }))

        default:
            return nil
        }
    }

    var object: NSObject {
        switch self {
        case let .array(value):         return value.map({ $0.object }) as NSArray
        case let .bool(value):          return value as NSNumber
        case let .data(value):          return value as NSData
        case let .dictionary(value):    return value.mapValues({ $0.object }) as NSDictionary
        case let .double(value):        return value as NSNumber
        case let .float(value):         return value as NSNumber
        case let .integer(value):       return value as NSNumber
        case .none:                     return NSNull()
        case let .string(value):        return value as NSString
        }
    }
}
