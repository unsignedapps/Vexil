//
//  FlagValueCompilationTests.swift
//  Vexil
//
//  Created by Rob Amos on 20/7/20.
//

@testable import Vexil
import XCTest

/// A series of trivial equality tests
///
/// These are here not because we need to test the setting or
/// retrieval of values of different types, but because
/// we want to ensure that if we break support for any
/// type of FlagValue we see compilation errors here
/// immediately.
///
///  For example, if we remove the `FlagValue` conformance
///  from `Bool` we'd expect to see the second line of
///  `testBooleanFlagValue` fail to compile
///
final class FlagValueCompilationTests: XCTestCase {

    // MARK: - Boolean Flag Values

    func testBooleanFlagValue () {
        let value = true
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - String Flag Values

    func testStringFlagValue () {
        let value = "Test"
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testURLFlagValue () {
        let value = URL(string: "https://google.com/")!
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Data and Date Flag Values

    func testDateFlagValue () {
        let value = Date()
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testDataFlagValue () {
        let value = Data()
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Integer Flag Values

    func testIntFlagValue () {
        let value: Int = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testInt8FlagValue () {
        let value: Int8 = 12
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testInt16FlagValue () {
        let value: Int16 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testInt32FlagValue () {
        let value: Int32 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testInt64FlagValue () {
        let value: Int64 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testUIntFlagValue () {
        let value: UInt = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testUInt8FlagValue () {
        let value: UInt8 = 12
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testUInt16FlagValue () {
        let value: UInt16 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testUInt32FlagValue () {
        let value: UInt32 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testUInt64FlagValue () {
        let value: UInt64 = 123
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Floating Point Flag Values

    func testFloatFlagValue () {
        let value: Float = 123.23
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testDoubleFlagValue () {
        let value: Double = 123.23
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Wrapping Types

    func testRawRepresentableFlagValue () {
        let value = TestStruct(rawValue: "Test")
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            var rawValue: String
        }
    }

    func testOptionalFlagValue () {
        let value: String? = "Test"
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testOptionalNoFlagValue () {
        let value: String? = nil
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Collection Types

    func testArrayFlagValue () {
        let value = [ 123, 456, 789 ]
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }

    func testDictionaryFlagValue () {
        let value = [ "First": 123, "Second": 456, "Third": 789 ]
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)
    }


    // MARK: - Codable Types

    func testCodableFlagValue () {
        let value = TestStruct()
        let pole = FlagPole(hoisting: TestFlags(default: value), sources: [])
        XCTAssertEqual(pole.flag, value)

        struct TestStruct: Codable, FlagValue, Equatable {
            let property1 = 123
            let property2 = "456"
            let property3 = 789.0
        }
    }

}


// MARK: - Generic Flag Time

private struct TestFlags<Value>: FlagContainer where Value: FlagValue {

    @Flag
    var flag: Value

    init (default value: Value) {
        self._flag = Flag(default: value, description: "Test flag")
    }

    init () {
        fatalError("This shouldn't be accessed during testing")
    }
}
