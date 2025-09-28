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

import Foundation
import Testing
@testable import Vexil

@Suite("UserDefaults Encoding", .tags(.userDefaults))
final class UserDefaultsEncodingTests {

    private let defaults: UserDefaults

    init() {
        self.defaults = UserDefaults(suiteName: "UserDefaultsEncodingTests")!
    }

    deinit {
        defaults.removePersistentDomain(forName: "UserDefaultsEncodingTests")
    }


    // MARK: - Removing Values

    @Test("Unsets values")
    func unsets() throws {
        try withUserDefaults(#function) { defaults in
            defaults.set(true, forKey: "test")
            #expect(defaults.object(forKey: "test") != nil)

            try defaults.setFlagValue(Bool?.none, key: "test")
            #expect(defaults.object(forKey: "test") == nil)
        }
    }


    // MARK: - Decoding Boolean Types

    @Test("Encodes boolean true")
    func booleanTrue() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(true, key: "test")
            #expect(defaults.bool(forKey: "test") == true)
        }
    }

    @Test("Encodes boolean false")
    func booleanFalse() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(false, key: "test")
            #expect(defaults.bool(forKey: "test") == false)
        }
    }


    // MARK: - Decoding String Types

    @Test("Encodes string")
    func string() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue("abcd1234", key: "test")
            #expect(defaults.string(forKey: "test") == "abcd1234")
        }
    }

    @Test("Encodes URL")
    func url() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(URL(string: "https://google.com/")!, key: "test")
            #expect(defaults.string(forKey: "test") == "https://google.com/")
        }
    }


    // MARK: - Encoding Float / Double Types

    @Test("Encodes double")
    func double() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(123.456, key: "test")
            #expect(defaults.double(forKey: "test") == 123.456)
        }
    }

    func float() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(Float(123.456), key: "test")
            #expect(defaults.float(forKey: "test") == Float(123.456))
        }
    }


    // MARK: - Encoding Integer Types

    @Test("Encodes integer")
    func int() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(1234, key: "test")
            #expect(defaults.integer(forKey: "test") == 1234)
        }
    }

    @Test("Encodes 8-bit integer")
    func int8() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(Int8(12), key: "test")
            #expect(defaults.integer(forKey: "test") == Int8(12))
        }
    }

    @Test("Encodes 16-bit integer")
    func int16() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(Int16(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == Int16(1234))
        }
    }

    @Test("Encodes 32-bit integer")
    func int32() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(Int32(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == Int32(1234))
        }
    }

    @Test("Encodes 64-bit integer")
    func int64() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(Int64(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == Int64(1234))
        }
    }

    @Test("Encodes unsigned integer")
    func uint() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(UInt(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == UInt(1234))
        }
    }

    @Test("Encodes 8-bit unsigned integer")
    func uint8() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(UInt8(12), key: "test")
            #expect(defaults.integer(forKey: "test") == UInt8(12))
        }
    }

    @Test("Encodes 16-bit unsigned integer")
    func uint16() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(UInt16(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == UInt16(1234))
        }
    }

    @Test("Encodes 32-bit unsigned integer")
    func uint32() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(UInt32(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == UInt32(1234))
        }
    }

    @Test("Encodes 64-bit unsigned integer")
    func uint64() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(UInt64(1234), key: "test")
            #expect(defaults.integer(forKey: "test") == UInt64(1234))
        }
    }


    // MARK: - Wrapping Types

    @Test("Encodes raw representable")
    func rawRepresentable() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(TestStruct(rawValue: "Test Value"), key: "test")
            #expect(defaults.string(forKey: "test") == "Test Value")

            struct TestStruct: RawRepresentable, FlagValue, Equatable {
                var rawValue: String
            }
        }
    }

    @Test("Encodes optional")
    func optional() throws {
        try withUserDefaults(#function) { defaults in
            let value: String? = "Test Value"

            try defaults.setFlagValue(value, key: "test")
            #expect(defaults.string(forKey: "test") == "Test Value")
        }
    }

    @Test("Encodes nil")
    func none() throws {
        try withUserDefaults(#function) { defaults in
            let value: String? = nil

            try defaults.setFlagValue(value, key: "test")
            #expect(defaults.string(forKey: "test") == nil)
        }
    }


    // MARK: - Array Tests

    @Test("Encodes string array")
    func stringArray() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue([ "abc", "123" ], key: "test")
            #expect(defaults.stringArray(forKey: "test") == [ "abc", "123" ])
        }
    }

    @Test("Encodes integer array")
    func integerArray() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue([ 234, -123 ], key: "test")
            #expect(defaults.array(forKey: "test") as? [Int] == [ 234, -123 ])
        }
    }


    // MARK: - Dictionary Tests

    @Test("Encodes string dictionary")
    func stringDictionary() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue([ "key1": "value1", "key2": "value2" ], key: "test")
            #expect(defaults.dictionary(forKey: "test") as? [String: String] == [ "key1": "value1", "key2": "value2" ])
        }
    }

    @Test("Encodes integer dictionary")
    func integerDictionary() throws {
        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue([ "key1": 123, "key2": -987 ], key: "test")
            #expect(defaults.dictionary(forKey: "test") as? [String: Int] == [ "key1": 123, "key2": -987 ])
        }
    }

    // MARK: - Codable Tests

    @Test("Encodes codable")
    func codable() throws {
        struct MyStruct: FlagValue, Codable, Equatable {
            let property1: String
            let property2: Int
            let property3: String

            init() {
                self.property1 = "value1"
                self.property2 = 123
                self.property3 = "🤯"
            }
        }

        let input = MyStruct()

        // manually encoding into json
        let expected = Data(#"{"wrapped":{"property1":"value1","property2":123,"property3":"🤯"}}"#.utf8)

        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(input, key: "test")
            #expect(defaults.data(forKey: "test") == expected)
        }
    }

}

/// Swift Testing runs tests inside a TaskGroup, which means sharing UserDefaults across multiple tests is fraught.
private func withUserDefaults(_ suite: String, _ closure: (UserDefaults) throws -> Void) rethrows {
    let defaults = UserDefaults(suiteName: suite)!
    try closure(defaults)
    defaults.removePersistentDomain(forName: suite)
}

#endif // !os(Linux)
