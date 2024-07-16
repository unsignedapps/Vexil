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

final class UserDefaultsDecodingTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(UserDefaultsDecodingTests.self, hostedBy: self)
    }
}

#endif

@Suite("UserDefaults Decoding", .tags(.userDefaults))
final class UserDefaultsDecodingTests {

    private let defaults: UserDefaults

    init() {
        self.defaults = UserDefaults(suiteName: "UserDefaultsDecodingTests")!
    }

    deinit {
        defaults.removePersistentDomain(forName: "UserDefaultsDecodingTests")
    }


    // MARK: - Decoding Missing Values

    @Test("Decodes missing value as nil")
    func missing() {
        #expect(defaults.flagValue(key: #function) as Bool? == nil)
    }

    @Test("Decodes unset value as nil")
    func unset() {
        defaults.set(true, forKey: #function)
        defaults.removeObject(forKey: #function)
        #expect(defaults.flagValue(key: #function) as Bool? == nil)
    }


    // MARK: - Decoding Boolean Types

    @Test("Decodes boolean true")
    func booleanTrue() {
        defaults.set(true, forKey: #function)
        #expect(defaults.flagValue(key: #function) == true)
    }

    @Test("Decodes boolean false")
    func booleanFalse() {
        defaults.set(false, forKey: #function)
        #expect(defaults.flagValue(key: #function) == false)
    }

    @Test("Decodes integer as boolean")
    func booleanInteger() {
        defaults.set(1, forKey: #function)
        #expect(defaults.flagValue(key: #function) == true)
    }

    @Test("Decodes double as boolean")
    func booleanDouble() {
        defaults.set(1.0, forKey: #function)
        #expect(defaults.flagValue(key: #function) == true)
    }

    @Test("Decodes string as boolean")
    func booleanString() {
        defaults.set("t", forKey: #function)
        #expect(defaults.flagValue(key: #function) == true)
    }


    // MARK: - Decoding String Types

    @Test("Decodes string")
    func string() {
        defaults.set("abcd1234", forKey: #function)
        #expect(defaults.flagValue(key: #function) == "abcd1234")
    }

    @Test("Decodes URL")
    func url() {
        defaults.set("https://google.com/", forKey: #function)
        #expect(defaults.flagValue(key: #function) == URL(string: "https://google.com/")!)
    }


    // MARK: - Decoding Float / Double Types

    @Test("Decodes double")
    func double() {
        defaults.set(123.456, forKey: #function)
        #expect(defaults.flagValue(key: #function) == 123.456)
    }

    @Test("Decodes float")
    func float() {
        defaults.set(Float(123.456), forKey: #function)
        #expect(defaults.flagValue(key: #function) == Float(123.456))
    }

    @Test("Decodes integer as double")
    func doubleinteger() {
        defaults.set(1, forKey: #function)
        #expect(defaults.flagValue(key: #function) == 1.0)
    }

    @Test("Decodes string as double")
    func doubleString() {
        defaults.set("1.23456789", forKey: #function)
        #expect(defaults.flagValue(key: #function) == 1.23456789)
    }


    // MARK: - Decoding Integer Types

    @Test("Decodes integer")
    func int() {
        defaults.set(1234, forKey: #function)
        #expect(defaults.flagValue(key: #function) == 1234)
    }

    @Test("Decodes 8-bit integer")
    func int8() {
        defaults.set(Int8(12), forKey: #function)
        #expect(defaults.flagValue(key: #function) == Int8(12))
    }

    @Test("Decodes 16-bit integer")
    func int16() {
        defaults.set(Int16(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == Int16(1234))
    }

    @Test("Decodes 32-bit integer")
    func int32() {
        defaults.set(Int32(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == Int32(1234))
    }

    @Test("Decodes 64-bit integer")
    func int64() {
        defaults.set(Int64(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == Int64(1234))
    }

    @Test("Decodes unsigned integer")
    func uint() {
        defaults.set(UInt(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt(1234))
    }

    @Test("Decodes 8-bit unsigned integer")
    func uint8() {
        defaults.set(UInt8(12), forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt8(12))
    }

    @Test("Decodes 16-bit unsigned integer")
    func uint16() {
        defaults.set(UInt16(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt16(1234))
    }

    @Test("Decodes 32-bit unsigned integer")
    func uint32() {
        defaults.set(UInt32(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt32(1234))
    }

    @Test("Decodes 64-bit unsigned integer")
    func uint64() {
        defaults.set(UInt64(1234), forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt64(1234))
    }

    @Test("Decodes string as integer")
    func intString() {
        defaults.set("1234", forKey: #function)
        #expect(defaults.flagValue(key: #function) == 1234)
    }

    @Test("Decodes string as unsigned integer")
    func uintString() {
        defaults.set("1234", forKey: #function)
        #expect(defaults.flagValue(key: #function) == UInt(1234))
    }


    // MARK: - Wrapping Types

    @Test("Decodes raw representable string")
    func rawRepresentableString() {
        defaults.set("Test Value", forKey: #function)
        #expect(defaults.flagValue(key: #function) == TestStruct(rawValue: "Test Value"))

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: String
        }
    }

    @Test("Decodes raw representable boolean")
    func rawRepresentableBool() {
        defaults.set(true, forKey: #function)
        #expect(defaults.flagValue(key: #function) == TestStruct(rawValue: true))

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: Bool
        }
    }

    // double optionals here because flagValue(key:) returns an optional, so Value is inferred as "String?" or "Bool?"

    @Test("Decodes optional boolean")
    func optionalBool() {
        defaults.set(true, forKey: #function)
        #expect(defaults.flagValue(key: #function) == Bool??.some(true))
    }

    @Test("Decodes optional string")
    func optionalString() {
        defaults.set("Test Value", forKey: #function)
        #expect(defaults.flagValue(key: #function) == String??.some("Test Value"))
    }

    @Test("Decodes nil")
    func optionalNil() {
        defaults.removeObject(forKey: #function)
        #expect(defaults.flagValue(key: #function) == String??.none)
    }

    @Test("Decodes string as optional boolean")
    func testOptionalBoolString() {
        defaults.set("t", forKey: #function)
        #expect(defaults.flagValue(key: #function) == Bool??.some(true))
    }

    // MARK: - Array Tests

    @Test("Decodes string array")
    func stringARray() {
        defaults.set([ "abc", "123" ], forKey: #function)
        #expect(defaults.flagValue(key: #function) == [ "abc", "123" ])
    }

    @Test("Decodes integer array")
    func integerArray() {
        defaults.set([ 234, -123 ], forKey: #function)
        #expect(defaults.flagValue(key: #function) == [ 234, -123 ])
    }


    // MARK: - Dictionary Tests

    @Test("Decodes string dictionary")
    func stringDictionary() {
        defaults.set([ "key1": "value1", "key2": "value2" ], forKey: #function)
        #expect(defaults.flagValue(key: #function) == [ "key1": "value1", "key2": "value2" ])
    }

    @Test("Decodes integer dictionary")
    func integerDictionary() {
        defaults.set([ "key1": 123, "key2": -987 ], forKey: #function)
        #expect(defaults.flagValue(key: #function) == [ "key1": 123, "key2": -987 ])
    }


    // MARK: - Codable Tests

    @Test("Decodes codable")
    func codable() {
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

        let expected = MyStruct()

        // manually encoding into json
        let input =
            """
                {
                    "wrapped": {
                        "property1": "value1",
                        "property2": 123,
                        "property3": "🤯"
                    }
                }
            """

        defaults.set(Data(input.utf8), forKey: #function)
        #expect(defaults.flagValue(key: #function) == expected)
    }

    @Test("Decodes enum")
    func enumeration() throws {
        enum MyEnum: String, FlagValue, Equatable {
            case one
            case two
        }

        try defaults.setFlagValue(MyEnum.one, key: #function)
        #expect(defaults.flagValue(key: #function) == MyEnum.one)
    }

}
