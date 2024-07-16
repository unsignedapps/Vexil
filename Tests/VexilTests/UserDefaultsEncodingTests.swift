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

import Foundation
import Testing
@testable import Vexil

#if compiler(<6)

import XCTest

final class UserDefaultsEncodingTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(UserDefaultsEncodingTests.self, hostedBy: self)
    }
}

#endif

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
        defaults.set(true, forKey: #function)
        #expect(defaults.object(forKey: #function) != nil)

        try defaults.setFlagValue(Bool?.none, key: #function)
        #expect(defaults.object(forKey: #function) == nil)
    }


    // MARK: - Decoding Boolean Types

    @Test("Encodes boolean true")
    func booleanTrue() throws {
        try defaults.setFlagValue(true, key: #function)
        #expect(defaults.bool(forKey: #function) == true)
    }

    @Test("Encodes boolean false")
    func booleanFalse() throws {
        try defaults.setFlagValue(false, key: #function)
        #expect(defaults.bool(forKey: #function) == false)
    }


    // MARK: - Decoding String Types

    @Test("Encodes string")
    func string() throws {
        try defaults.setFlagValue("abcd1234", key: #function)
        #expect(defaults.string(forKey: #function) == "abcd1234")
    }

    @Test("Encodes URL")
    func url() throws {
        try defaults.setFlagValue(URL(string: "https://google.com/")!, key: #function)
        #expect(defaults.string(forKey: #function) == "https://google.com/")
    }


    // MARK: - Encoding Float / Double Types

    @Test("Encodes double")
    func double() throws {
        try defaults.setFlagValue(123.456, key: #function)
        #expect(defaults.double(forKey: #function) == 123.456)
    }

    func float() throws {
        try defaults.setFlagValue(Float(123.456), key: #function)
        #expect(defaults.float(forKey: #function) == Float(123.456))
    }


    // MARK: - Encoding Integer Types

    @Test("Encodes integer")
    func int() throws {
        try defaults.setFlagValue(1234, key: #function)
        #expect(defaults.integer(forKey: #function) == 1234)
    }

    @Test("Encodes 8-bit integer")
    func int8() throws {
        try defaults.setFlagValue(Int8(12), key: #function)
        #expect(defaults.integer(forKey: #function) == Int8(12))
    }

    @Test("Encodes 16-bit integer")
    func int16() throws {
        try defaults.setFlagValue(Int16(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == Int16(1234))
    }

    @Test("Encodes 32-bit integer")
    func int32() throws {
        try defaults.setFlagValue(Int32(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == Int32(1234))
    }

    @Test("Encodes 64-bit integer")
    func int64() throws {
        try defaults.setFlagValue(Int64(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == Int64(1234))
    }

    @Test("Encodes unsigned integer")
    func uint() throws {
        try defaults.setFlagValue(UInt(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == UInt(1234))
    }

    @Test("Encodes 8-bit unsigned integer")
    func uint8() throws {
        try defaults.setFlagValue(UInt8(12), key: #function)
        #expect(defaults.integer(forKey: #function) == UInt8(12))
    }

    @Test("Encodes 16-bit unsigned integer")
    func uint16() throws {
        try defaults.setFlagValue(UInt16(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == UInt16(1234))
    }

    @Test("Encodes 32-bit unsigned integer")
    func uint32() throws {
        try defaults.setFlagValue(UInt32(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == UInt32(1234))
    }

    @Test("Encodes 64-bit unsigned integer")
    func uint64() throws {
        try defaults.setFlagValue(UInt64(1234), key: #function)
        #expect(defaults.integer(forKey: #function) == UInt64(1234))
    }


    // MARK: - Wrapping Types

    @Test("Encodes raw representable")
    func rawRepresentable() throws {
        try defaults.setFlagValue(TestStruct(rawValue: "Test Value"), key: #function)
        #expect(defaults.string(forKey: #function) == "Test Value")

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: String
        }
    }

    @Test("Encodes optional")
    func optional() throws {
        let value: String? = "Test Value"

        try defaults.setFlagValue(value, key: #function)
        #expect(defaults.string(forKey: #function) == "Test Value")
    }

    @Test("Encodes nil")
    func none() throws {
        let value: String? = nil

        try defaults.setFlagValue(value, key: #function)
        #expect(defaults.string(forKey: #function) == nil)
    }


    // MARK: - Array Tests

    @Test("Encodes string array")
    func stringArray() throws {
        try defaults.setFlagValue([ "abc", "123" ], key: #function)
        #expect(defaults.stringArray(forKey: #function) == [ "abc", "123" ])
    }

    @Test("Encodes integer array")
    func integerArray() throws {
        try defaults.setFlagValue([ 234, -123 ], key: #function)
        #expect(defaults.array(forKey: #function) as? [Int] == [ 234, -123 ])
    }


    // MARK: - Dictionary Tests

    @Test("Encodes string dictionary")
    func stringDictionary() throws {
        try defaults.setFlagValue([ "key1": "value1", "key2": "value2" ], key: #function)
        #expect(defaults.dictionary(forKey: #function) as? [String: String] == [ "key1": "value1", "key2": "value2" ])
    }

    @Test("Encodes integer dictionary")
    func integerDictionary() throws {
        try defaults.setFlagValue([ "key1": 123, "key2": -987 ], key: #function)
        #expect(defaults.dictionary(forKey: #function) as? [String: Int] == [ "key1": 123, "key2": -987 ])
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

        try defaults.setFlagValue(input, key: #function)
        #expect(defaults.data(forKey: #function) == expected)
    }

}
