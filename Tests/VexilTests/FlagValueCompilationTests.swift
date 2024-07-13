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

    func testBooleanFlagValue() {
        let pole = FlagPole(hoist: BooleanTestFlags.self, sources: [])
        XCTAssertTrue(pole.flag)
    }


    // MARK: - String Flag Values

    func testStringFlagValue() {
        let pole = FlagPole(hoist: StringTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, "Test")
    }

    func testURLFlagValue() {
        let pole = FlagPole(hoist: URLTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, URL(string: "https://google.com/")!)
    }


    // MARK: - Data and Date Flag Values

    func testDataFlagValue() {
        let pole = FlagPole(hoist: DataTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, Data("hello".utf8))
    }

    func testDateFlagValue() {
        class TestSource: NonSendableFlagValueSource {
            let name = "Test"
            let value = Date.now
            func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
                Value(boxedFlagValue: value.boxedFlagValue)
            }

            func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
                fatalError()
            }

            var changeStream: EmptyFlagChangeStream {
                .init()
            }
        }

        let source = TestSource()
        let pole = FlagPole(hoist: DateTestFlags.self, sources: [ FlagValueSourceCoordinator(source: source) ])
        XCTAssertEqual(pole.flag.timeIntervalSinceReferenceDate, source.value.timeIntervalSinceReferenceDate, accuracy: 0.1)
    }


    // MARK: - Integer Flag Values

    func testIntFlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testInt8FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int8>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testInt16FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int16>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testInt32FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int32>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testInt64FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int64>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testUIntFlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testUInt8FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt8>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testUInt16FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt16>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testUInt32FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt32>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }

    func testUInt64FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt64>.self, sources: [])
        XCTAssertEqual(pole.flag, 123)
    }


    // MARK: - Floating Point Flag Values

    func testFloatFlagValue() {
        let pole = FlagPole(hoist: FloatTestFlags<Float>.self, sources: [])
        XCTAssertEqual(pole.flag, 123.23, accuracy: 0.01)
    }

    func testDoubleFlagValue() {
        func testFloatFlagValue() {
            let pole = FlagPole(hoist: FloatTestFlags<Double>.self, sources: [])
            XCTAssertEqual(pole.flag, 123.23, accuracy: 0.01)
        }
    }


    // MARK: - Wrapping Types

    func testRawRepresentableFlagValue() {
        let pole = FlagPole(hoist: RawRepresentableTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, RawRepresentableTestStruct(rawValue: "Test"))
    }

    func testOptionalFlagValue() {
        let pole = FlagPole(hoist: OptionalValueTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, "Test")
    }

    func testOptionalNoFlagValue() {
        let pole = FlagPole(hoist: OptionalNoValueTestFlags.self, sources: [])
        XCTAssertNil(pole.flag)
    }


    // MARK: - Collection Types

    func testArrayFlagValue() {
        let pole = FlagPole(hoist: ArrayTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, [ 123, 456, 789 ])
    }

    func testDictionaryFlagValue() {
        let pole = FlagPole(hoist: DictionaryTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, [ "First": 123, "Second": 456, "Third": 789 ])
    }


    // MARK: - Codable Types

    func testCodableFlagValue() {
        let pole = FlagPole(hoist: CodableTestFlags.self, sources: [])
        XCTAssertEqual(pole.flag, CodableTestStruct())
    }

}

// MARK: - Fixtures

// It looks like conformance macros can't be added to types declared in function
// bodies because then it puts the extension inside the function body too, which
// confuses it, so we declare these separately even though its duplicated code

@FlagContainer
private struct BooleanTestFlags {
    @Flag(default: true, description: "Test Flag")
    var flag: Bool
}

@FlagContainer
private struct StringTestFlags {
    @Flag(default: "Test", description: "Test Flag")
    var flag: String
}

@FlagContainer
private struct URLTestFlags {
    @Flag(default: URL(string: "https://google.com/")!, description: "Test Flag")
    var flag: URL
}

@FlagContainer
private struct DateTestFlags {
    @Flag(default: Date.now, description: "Test Flag")
    var flag: Date
}

@FlagContainer
private struct DataTestFlags {
    @Flag(default: Data("hello".utf8), description: "Test Flag")
    var flag: Data
}

@FlagContainer(generateEquatable: false)
private struct IntTestFlags<Value> where Value: FlagValue & ExpressibleByIntegerLiteral {
    @Flag(default: 123, description: "Test flag")
    var flag: Value
}

@FlagContainer(generateEquatable: false)
private struct FloatTestFlags<Value> where Value: FlagValue & ExpressibleByFloatLiteral {
    @Flag(default: 123.23, description: "Test flag")
    var flag: Value
}

private struct RawRepresentableTestStruct: RawRepresentable, FlagValue, Equatable {
    var rawValue: String
}

@FlagContainer
private struct RawRepresentableTestFlags {
    @Flag(default: RawRepresentableTestStruct(rawValue: "Test"), description: "Test flag")
    var flag: RawRepresentableTestStruct
}

@FlagContainer
private struct OptionalValueTestFlags {
    @Flag(default: "Test", description: "Test flas")
    var flag: String?
}

@FlagContainer
private struct OptionalNoValueTestFlags {
    @Flag(default: String?.none, description: "Test flag")
    var flag: String?
}

@FlagContainer
private struct ArrayTestFlags {
    @Flag(default: [ 123, 456, 789 ], description: "Test flag")
    var flag: [Int]
}

@FlagContainer
private struct DictionaryTestFlags {
    @Flag(default: [ "First": 123, "Second": 456, "Third": 789 ], description: "Test flag")
    var flag: [String: Int]
}

private struct CodableTestStruct: Codable, FlagValue, Equatable {
    let property1: Int
    let property2: String
    let property3: Double

    init() {
        self.property1 = 123
        self.property2 = "456"
        self.property3 = 789.0
    }
}

@FlagContainer
private struct CodableTestFlags {
    @Flag(default: CodableTestStruct(), description: "Test flag")
    var flag: CodableTestStruct
}
