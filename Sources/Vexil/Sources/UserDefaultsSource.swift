//
//  UserDefaults.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

#if !os(Linux)
import Combine
#endif

import Foundation

// swiftlint:disable cyclomatic_complexity function_body_length

extension UserDefaults: FlagValueSource {

    public var name: String {
        return "UserDefaults\(self == UserDefaults.standard ? ".standard" : "")"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {

        guard
            let object = self.object(forKey: key),
            let boxed = BoxedFlagValue(object: object)
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


// MARK: - Unboxing

private extension BoxedFlagValue {
    init? (object: Any) {
        switch object {
//        case let value as NSNumber:
//            let numberType = CFNumberGetType(value)
//            switch numberType {
//            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .shortType, .intType, .longType, .longLongType, .nsIntegerType, .cfIndexType:
//                self = .integer(value.intValue)
//
//            case .float32Type, .float64Type, .floatType, .doubleType, .cgFloatType:
//                self = .double(value.doubleValue)
//
//            case .charType:
//                self = .bool(value.boolValue)
//
//            @unknown default:
//                return nil
//            }

        case let value as Bool:                     self = .bool(value)
        case let value as Data:                     self = .data(value)
        case let value as Int:                      self = .integer(value)
        case let value as Float:                    self = .float(value)
        case let value as Double:                   self = .double(value)
        case let value as String:                   self = .string(value)

        case let value as Array<Any>:               self = .array(value.compactMap({ BoxedFlagValue(object: $0) }))
        case let value as Dictionary<String, Any>:  self = .dictionary(value.compactMapValues({ BoxedFlagValue(object: $0) }))

        default:
            return nil
        }
    }

    var object: NSObject {
        switch self {
        case let .bool(value):          return NSNumber(booleanLiteral: value)
        case let .string(value):        return value as NSString
        case let .data(value):          return value as NSData
        case let .double(value):        return NSNumber(value: value)
        case let .float(value):         return NSNumber(value: value)
        case let .integer(value):       return NSNumber(value: value)
        case let .array(value):         return value.map({ $0.object }) as NSArray
        case let .dictionary(value):    return value.mapValues({ $0.object }) as NSDictionary
        }
    }
}
