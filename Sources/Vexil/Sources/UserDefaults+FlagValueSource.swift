//
//  UserDefaults+FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

#if !os(Linux)
import Combine
#endif

import Foundation

/// Provides support for using `UserDefaults` as a `FlagValueSource`
///
extension UserDefaults: FlagValueSource {

    public var name: String {
        return "UserDefaults\(self == UserDefaults.standard ? ".standard" : "")"
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

    }

    #if !os(Linux)

    public var valuesDidChange: AnyPublisher<Void, Never>? {
        return NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    #endif
}
