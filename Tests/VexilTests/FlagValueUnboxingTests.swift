//
//  FlagValueUnboxingTests.swift
//  Vexil
//
//  Created by Rob Amos on 21/7/20.
//

@testable import Vexil
import XCTest

final class FlagValueUnboxingTests: XCTestCase {

    // MARK: - Boolean Flag Values

    func testBooleanTrueFlagValue () {
        let boxed = BoxedFlagValue.bool(true)
        let expected = true

        XCTAssertEqual(Bool(boxedFlagValue: boxed), expected)
    }

    func testBooleanFalseFlagValue () {
        let boxed = BoxedFlagValue.bool(false)
        let expected = false

        XCTAssertEqual(Bool(boxedFlagValue: boxed), expected)
    }


    // MARK: - String Flag Values

    func testStringFlagValue () {
        let boxed = BoxedFlagValue.string("Test String")
        let expected = "Test String"

        XCTAssertEqual(String(boxedFlagValue: boxed), expected)
    }

    func testURLStringFlagValue () {
        let boxed = BoxedFlagValue.string("https://google.com/")
        let expected = URL(string: "https://google.com/")!

        XCTAssertEqual(URL(boxedFlagValue: boxed), expected)
    }


    // MARK: - Data and Date Types

    func testDataFlagValue () {
        let expected = Data("Test string".utf8)
        let boxed = BoxedFlagValue.data(expected)

        XCTAssertEqual(Data(boxedFlagValue: boxed), expected)
    }

    func testDateFlagValue () {
        AssertNoThrow {
            let expected = Date()
            let formatter = ISO8601DateFormatter()
            let boxed = BoxedFlagValue.string(formatter.string(from: expected))

            let calendar = Calendar(identifier: .gregorian)
            guard let date = Date(boxedFlagValue: boxed) else {
                throw Error.couldNotUnboxDate
            }

            XCTAssertEqual(calendar.compare(expected, to: date, toGranularity: .second), .orderedSame)
        }

        enum Error: Swift.Error {
            case couldNotUnboxDate
        }
    }


    // MARK: - Integer Flag Values

    func testIntFlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: Int = 123

        XCTAssertEqual(Int(boxedFlagValue: boxed), expected)
    }

    func testInt8FlagValue () {
        let boxed = BoxedFlagValue.integer(12)
        let expected: Int8 = 12

        XCTAssertEqual(Int8(boxedFlagValue: boxed), expected)
    }

    func testInt16FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: Int16 = 123

        XCTAssertEqual(Int16(boxedFlagValue: boxed), expected)
    }

    func testInt32FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: Int32 = 123

        XCTAssertEqual(Int32(boxedFlagValue: boxed), expected)
    }

    func testInt64FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: Int64 = 123

        XCTAssertEqual(Int64(boxedFlagValue: boxed), expected)
    }

    func testUIntFlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: UInt = 123

        XCTAssertEqual(UInt(boxedFlagValue: boxed), expected)
    }

    func testUInt8FlagValue () {
        let boxed = BoxedFlagValue.integer(12)
        let expected: UInt8 = 12

        XCTAssertEqual(UInt8(boxedFlagValue: boxed), expected)
    }

    func testUInt16FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: UInt16 = 123

        XCTAssertEqual(UInt16(boxedFlagValue: boxed), expected)
    }

    func testUInt32FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: UInt32 = 123

        XCTAssertEqual(UInt32(boxedFlagValue: boxed), expected)
    }

    func testUInt64FlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: UInt64 = 123

        XCTAssertEqual(UInt64(boxedFlagValue: boxed), expected)
    }


    // MARK: - Floating Point Flag Values

    func testFloatFlagValue () {
        let boxed = BoxedFlagValue.float(123.456)
        let expected: Float = 123.456

        let result = Float(boxedFlagValue: boxed)
        XCTAssertNotNil(result)

        if let result = result {
            XCTAssertEqual(result, expected, accuracy: 0.0001)
        }
    }

    func testDoubleFlagValue () {
        let boxed = BoxedFlagValue.double(123.456)
        let expected: Double = 123.456

        let result = Double(boxedFlagValue: boxed)
        XCTAssertNotNil(result)

        if let result = result {
            XCTAssertEqual(result, expected, accuracy: 0.0001)
        }
    }


    // MARK: - Wrapping Types

    func testRawRepresentableFlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected = TestStruct(rawValue: 123)

        XCTAssertEqual(TestStruct(boxedFlagValue: boxed), expected)


        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            let rawValue: Int
        }
    }

    func testOptionalSomeFlagValue () {
        let boxed = BoxedFlagValue.integer(123)
        let expected: Int? = 123

        XCTAssertEqual(Int?(boxedFlagValue: boxed), expected)
    }

    func testOptionalNoFlagValue () {
        let boxed = BoxedFlagValue.none
        let expected: Int? = nil

        XCTAssertEqual(Int?(boxedFlagValue: boxed), expected)
    }


    // MARK: - Collection Types

    func testArrayFlagValue () {
        let boxed = BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ])
        let expected = [ 123, 456, 789 ]

        XCTAssertEqual([Int](boxedFlagValue: boxed), expected)
    }

    func testDictionaryFlagValue () {
        let boxed = BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])
        let expected = [ "one": 123, "two": 456, "three": 789 ]

        XCTAssertEqual([String: Int](boxedFlagValue: boxed), expected)
    }


    // MARK: - Codable Types

    func testCodableFlagValue () {
        AssertNoThrow {
            let expected = TestStruct()
            let data = try JSONEncoder().encode(Wrapper(wrapped: expected))
            let boxed = BoxedFlagValue.data(data)

            XCTAssertEqual(TestStruct(boxedFlagValue: boxed), expected)
        }

        struct TestStruct: Codable, FlagValue, Equatable {
            let property1 = 123
            let property2 = "456"
            let property3 = 789.0
        }
    }
}
