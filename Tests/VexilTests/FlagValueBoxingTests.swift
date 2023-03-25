//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

@testable import Vexil
import XCTest

final class FlagValueBoxingTests: XCTestCase {

    // MARK: - Boolean Flag Values

    func testBooleanTrueFlagValue() {
        let input = true
        let expected = BoxedFlagValue.bool(true)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testBooleanFalseFlagValue() {
        let input = false
        let expected = BoxedFlagValue.bool(false)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - String Flag Values

    func testStringFlagValue() {
        let input = "Test String"
        let expected = BoxedFlagValue.string("Test String")

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testURLStringFlagValue() {
        let input = URL(string: "https://google.com/")!
        let expected = BoxedFlagValue.string("https://google.com/")

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Data and Date Types

    func testDataFlagValue() {
        let input = Data("Test string".utf8)
        let expected = BoxedFlagValue.data(input)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testDateFlagValue() {
        let input = Date()
        let formatter = ISO8601DateFormatter()
        let expected = BoxedFlagValue.string(formatter.string(from: input))

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Integer Flag Values

    func testIntFlagValue() {
        let input = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testInt8FlagValue() {
        let input: Int8 = 12
        let expected = BoxedFlagValue.integer(12)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testInt16FlagValue() {
        let input: Int16 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testInt32FlagValue() {
        let input: Int32 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testInt64FlagValue() {
        let input: Int64 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testUIntFlagValue() {
        let input: UInt = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testUInt8FlagValue() {
        let input: UInt8 = 12
        let expected = BoxedFlagValue.integer(12)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testUInt16FlagValue() {
        let input: UInt16 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testUInt32FlagValue() {
        let input: UInt32 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testUInt64FlagValue() {
        let input: UInt64 = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Floating Point Flag Values

    func testFloatFlagValue() {
        let input: Float = 123.456
        let expected = BoxedFlagValue.float(123.456)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testDoubleFlagValue() {
        let input = 123.456
        let expected = BoxedFlagValue.double(123.456)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Wrapping Types

    func testRawRepresentableFlagValue() {
        let input = TestStruct(rawValue: 123)
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)


        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            let rawValue: Int
        }
    }

    func testOptionalSomeFlagValue() {
        let input: Int? = 123
        let expected = BoxedFlagValue.integer(123)

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testOptionalNoFlagValue() {
        let input: Int? = nil
        let expected = BoxedFlagValue.none

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Collection Types

    func testArrayFlagValue() {
        let input = [ 123, 456, 789 ]
        let expected = BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ])

        XCTAssertEqual(input.boxedFlagValue, expected)
    }

    func testDictionaryFlagValue() {
        let input = [ "one": 123, "two": 456, "three": 789 ]
        let expected = BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])

        XCTAssertEqual(input.boxedFlagValue, expected)
    }


    // MARK: - Codable Types

    func testCodableFlagValue() {
        AssertNoThrow {
            let input = TestStruct()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try encoder.encode(Wrapper(wrapped: input))
            let expected = BoxedFlagValue.data(data)

            XCTAssertEqual(input.boxedFlagValue, expected)
        }

        struct TestStruct: Codable, FlagValue, Equatable {
            let property1: Int
            let property2: String
            let property3: Double

            init() {
                self.property1 = 123
                self.property2 = "456"
                self.property3 = 789.0
            }
        }
    }
}
