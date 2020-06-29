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

        // this is not ideal to copy the value out of preferences twice, but the alternative
        // is we replicate the entire type unboxing found in UserDefaults
        guard self.object(forKey: key) != nil else { return nil }

        if Value.self == Bool.self {
            return self.bool(forKey: key) as? Value
        } else if Value.self == String.self {
            return self.string(forKey: key) as? Value
        } else if Value.self == URL.self {
            guard let urlString = self.string(forKey: key), let url = URL(string: urlString) else { return nil }
            return url as? Value
        } else if Value.self == Double.self {
            return self.double(forKey: key) as? Value
        } else if Value.self == Float.self {
            return self.float(forKey: key) as? Value
        } else if Value.self == Int.self {
            return self.integer(forKey: key) as? Value
        } else if Value.self == Int8.self {
            return Int8(self.integer(forKey: key)) as? Value
        } else if Value.self == Int16.self {
            return Int16(self.integer(forKey: key)) as? Value
        } else if Value.self == Int32.self {
            return Int32(self.integer(forKey: key)) as? Value
        } else if Value.self == Int64.self {
            return Int64(self.integer(forKey: key)) as? Value
        } else if Value.self == UInt.self {
            return UInt(self.integer(forKey: key)) as? Value
        } else if Value.self == UInt8.self {
            return UInt8(self.integer(forKey: key)) as? Value
        } else if Value.self == UInt16.self {
            return UInt16(self.integer(forKey: key)) as? Value
        } else if Value.self == UInt32.self {
            return UInt32(self.integer(forKey: key)) as? Value
        } else if Value.self == UInt64.self {
            return UInt64(self.integer(forKey: key)) as? Value

        // arrays we blindly try to cast
        } else if let array = self.array(forKey: key) {
            return array as? Value

        // dictionaries we decode if we can't cast
        } else if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            return (try? decoder.decode(Wrapper<Value>.self, from: data))?.wrapped
        }

        return nil
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        guard let value = value else {
            self.removeObject(forKey: key)
            return
        }

        if let value = value as? Bool {
            self.set(value, forKey: key)
        } else if let value = value as? String {
            self.set(value, forKey: key)
        } else if let value = value as? URL {
            self.set(value.absoluteString, forKey: key)
        } else if let value = value as? Double {
            self.set(value, forKey: key)
        } else if let value = value as? Float {
            self.set(value, forKey: key)
        } else if let value = value as? Int {
            self.set(value, forKey: key)
        } else if let value = value as? Int8 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? Int16 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? Int32 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? Int64 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? UInt {
            self.set(Int(value), forKey: key)
        } else if let value = value as? UInt8 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? UInt16 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? UInt32 {
            self.set(Int(value), forKey: key)
        } else if let value = value as? UInt64 {
            self.set(Int(value), forKey: key)

        } else if let value = value as? [FlagValue] {
            self.set(value, forKey: key)
        } else if let value = value as? [String: FlagValue] {
            self.set(value, forKey: key)

        } else {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            self.set(try encoder.encode(Wrapper(wrapped: value)), forKey: key)
        }
    }

    #if !os(Linux)

    public var valuesDidChange: AnyPublisher<Void, Never>? {
        return NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    #endif
}


// MARK: - Encoding Wrapper

// Because we can't encode/decode a JSON fragment in Swift 5.2 on Linux we wrap it in this.
fileprivate struct Wrapper<Wrapped>: Codable where Wrapped: Codable {
    var wrapped: Wrapped
}
