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

@testable import Vexil
import XCTest

final class UserDefaultsDecodingTests: XCTestCase {

    // MARK: - Fixtures

    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "UserDefaultsDecodingTests")
    }

    override func tearDown() {
        super.tearDown()
        defaults.removePersistentDomain(forName: "UserDefaultsDecodingTests")
    }


    // MARK: - Decoding Missing Values

    func testDecodeMissingClean() {
        let value: Bool? = defaults.flagValue(key: #function)
        XCTAssertNil(value)
    }

    func testDecodeMissingUnset() {
        defaults.set(true, forKey: #function)
        defaults.removeObject(forKey: #function)

        let value: Bool? = defaults.flagValue(key: #function)
        XCTAssertNil(value)
    }


    // MARK: - Decoding Boolean Types

    func testDecodeBooleanTrue() {
        let value = true

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeBooleanFalse() {
        let value = false

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeBooleanInt() {
        let value = 1

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), true)       // swiftlint:disable:this xct_specific_matcher
    }

    func testDecodeBooleanDouble() {
        let value = 1.0

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), true)       // swiftlint:disable:this xct_specific_matcher
    }

    func testDecodeBooleanString() {
        let value = "t"

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), true)       // swiftlint:disable:this xct_specific_matcher
    }


    // MARK: - Decoding String Types

    func testDecodeString() {
        let value = "abcd1234"

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeURL() {
        let value = URL(string: "https://google.com/")!

        defaults.set(value.absoluteString, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }


    // MARK: - Decoding Float / Double Types

    func testDecodeDouble() {
        let value = Double(1.23456789)

        defaults.set(value, forKey: #function)
        let result: Double? = defaults.flagValue(key: #function)
        XCTAssertNotNil(result)
        if let result {
            XCTAssertEqual(result, value, accuracy: 0.000001)
        }
    }

    func testDecodeFloat() {
        let value = Float(1.23456789)

        defaults.set(value, forKey: #function)
        let result: Float? = defaults.flagValue(key: #function)
        XCTAssertNotNil(result)
        if let result {
            XCTAssertEqual(result, value, accuracy: 0.000001)
        }
    }

    func testDecodeDoubleInt() {
        let value = 1

        defaults.set(value, forKey: #function)
        let result: Double? = defaults.flagValue(key: #function)
        XCTAssertNotNil(result)
        if let result {
            XCTAssertEqual(result, 1.0, accuracy: 0.000001)
        }
    }

    func testDecodeDoubleString() {
        let value = "1.23456789"

        defaults.set(value, forKey: #function)
        let result: Double? = defaults.flagValue(key: #function)
        XCTAssertNotNil(result)
        if let result {
            XCTAssertEqual(result, 1.23456789, accuracy: 0.000001)
        }
    }


    // MARK: - Decoding Integer Types

    func testDecodeInt() {
        let value = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeInt8() {
        let value: Int8 = 12

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeInt16() {
        let value: Int16 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeInt32() {
        let value: Int32 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeInt64() {
        let value: Int64 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeUInt() {
        let value: UInt = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeUInt8() {
        let value: UInt8 = 12

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeUInt16() {
        let value: UInt16 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeUInt32() {
        let value: UInt32 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeUInt64() {
        let value: UInt64 = 1234

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeIntString() {
        let value = "1234"

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), 1234)
    }

    func testDecodeUIntString() {
        let value = "1234"

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), UInt(1234))
    }


    // MARK: - Wrapping Types

    func testRawRepresentableString() {
        let value = TestStruct(rawValue: "Test Value")

        defaults.set(value.rawValue, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: String
        }
    }

    func testRawRepresentableBool() {
        let value = TestStruct(rawValue: true)

        defaults.set(value.rawValue, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: Bool
        }
    }

    // double optionals here because flagValue(key:) returns an optional, so Value is inferred as "String?" or "Bool?"

    func testOptionalBool() {
        let value: Bool?? = true

        defaults.set(true, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testOptionalString() {
        let value: String?? = "Test Value"

        defaults.set(value!, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testOptionalNone() {
        let value: String?? = nil

        defaults.removeObject(forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testOptionalBoolString() {
        let value = "t"
        let expected: Bool?? = true

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), expected)
    }

    // MARK: - Array Tests

    func testDecodeStringArray() {
        let value = [ "abc", "123" ]

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }

    func testDecodeIntegerArray() {
        let value = [ 234, -123 ]

        defaults.set(value, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), value)
    }


    // MARK: - Dictionary Tests

    func testDecodeStringDictionary() {
        let expected = [
            "key1": "value1",
            "key2": "value2",
        ]

        defaults.set(expected, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), expected)
    }

    func testDecodeIntegerDictionary() {
        let expected = [
            "key1": 123,
            "key2": -987,
        ]

        defaults.set(expected, forKey: #function)
        XCTAssertEqual(defaults.flagValue(key: #function), expected)
    }


    // MARK: - Codable Tests

    func testDecodeCodable() {
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
        XCTAssertEqual(defaults.flagValue(key: #function), expected)
    }

    func testDecodeEnum() {
        enum MyEnum: String, FlagValue, Equatable {
            case one
            case two
        }

        AssertNoThrow {
            let expected = MyEnum.one
            try self.defaults.setFlagValue(expected, key: #function)
            XCTAssertEqual(self.defaults.flagValue(key: #function), expected)
        }
    }

}
