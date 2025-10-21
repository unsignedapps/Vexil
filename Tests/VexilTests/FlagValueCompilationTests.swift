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

import Foundation
import Testing
@testable import Vexil

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
@Suite("Flag Value Compilation", .tags(.pole))
struct FlagValueCompilationTests {

    // MARK: - Boolean Flag Values

    @Test("Compiles boolean")
    func booleanFlagValue() {
        let pole = FlagPole(hoist: BooleanTestFlags.self, sources: [])
        #expect(pole.flag)
    }


    // MARK: - String Flag Values

    @Test("Compiles string")
    func stringFlagValue() {
        let pole = FlagPole(hoist: StringTestFlags.self, sources: [])
        #expect(pole.flag == "Test")
    }

    @Test("Compiles URL")
    func urlFlagValue() {
        let pole = FlagPole(hoist: URLTestFlags.self, sources: [])
        #expect(pole.flag == URL(string: "https://google.com/")!)
    }


    // MARK: - Data and Date Flag Values

    @Test("Compiles data")
    func dataFlagValue() {
        let pole = FlagPole(hoist: DataTestFlags.self, sources: [])
        #expect(pole.flag == Data("hello".utf8))
    }

    @Test("Compiles date", .tags(.source))
    func dateFlagValue() {
        // We need to use a source here to ensure that the expected value is *exactly* what it was
        let source = TestSource()
        let pole = FlagPole(hoist: DateTestFlags.self, sources: [ source ])
        #expect(pole.flag.timeIntervalSinceReferenceDate == source.value.timeIntervalSinceReferenceDate)

        final class TestSource: FlagValueSource {
            let flagValueSourceID = UUID().uuidString
            let flagValueSourceName: String = "Test"
            let value = Date.now
            func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
                value as? Value
            }

            func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
                fatalError()
            }

            func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> EmptyFlagChangeStream {
                .init()
            }
        }
    }


    // MARK: - Integer Flag Values

    @Test("Compiles integer")
    func intFlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 8-bit integer")
    func int8FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int8>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 16-bit integer")
    func int16FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int16>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 32-bit integer")
    func int32FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int32>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 64-bit integer")
    func int64FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<Int64>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles unsigned integer")
    func uIntFlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 8-bit unsigned integer")
    func uint8FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt8>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 16-bit unsigned integer")
    func uint16FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt16>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 32-bit unsigned integer")
    func uint32FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt32>.self, sources: [])
        #expect(pole.flag == 123)
    }

    @Test("Compiles 64-bit unsigned integer")
    func uint64FlagValue() {
        let pole = FlagPole(hoist: IntTestFlags<UInt64>.self, sources: [])
        #expect(pole.flag == 123)
    }


    // MARK: - Floating Point Flag Values

    @Test("Compiles float")
    func floatFlagValue() {
        let pole = FlagPole(hoist: FloatTestFlags<Float>.self, sources: [])
        #expect(pole.flag == 123.23)
    }

    @Test("Compiles double")
    func doubleFlagValue() {
        let pole = FlagPole(hoist: FloatTestFlags<Double>.self, sources: [])
        #expect(pole.flag == 123.23)
    }


    // MARK: - Wrapping Types

    @Test("Compiles raw representable")
    func rawRepresentableFlagValue() {
        let pole = FlagPole(hoist: RawRepresentableTestFlags.self, sources: [])
        #expect(pole.flag == RawRepresentableTestStruct(rawValue: "Test"))
    }

    @Test("Compiles optional")
    func optionalFlagValue() {
        let pole = FlagPole(hoist: OptionalValueTestFlags.self, sources: [])
        #expect(pole.flag == "Test")
    }

    @Test("Compiles nil")
    func optionalNoFlagValue() {
        let pole = FlagPole(hoist: OptionalNoValueTestFlags.self, sources: [])
        #expect(pole.flag == nil)
    }


    // MARK: - Collection Types

    @Test("Compiles array")
    func arrayFlagValue() {
        let pole = FlagPole(hoist: ArrayTestFlags.self, sources: [])
        #expect(pole.flag == [ 123, 456, 789 ])
    }

    @Test("Compiles dictionary")
    func dictionaryFlagValue() {
        let pole = FlagPole(hoist: DictionaryTestFlags.self, sources: [])
        #expect(pole.flag == [ "First": 123, "Second": 456, "Third": 789 ])
    }


    // MARK: - Codable Types

    @Test("Compiles codable")
    func codableFlagValue() {
        let pole = FlagPole(hoist: CodableTestFlags.self, sources: [])
        #expect(pole.flag == CodableTestStruct())
    }

}

// MARK: - Fixtures

// It looks like conformance macros can't be added to types declared in function
// bodies because then it puts the extension inside the function body too, which
// confuses it, so we declare these separately even though its duplicated code

@FlagContainer
private struct BooleanTestFlags {
    @Flag("Test Flag")
    var flag = true
}

@FlagContainer
private struct StringTestFlags {
    @Flag("Test Flag")
    var flag = "Test"
}

@FlagContainer
private struct URLTestFlags {
    @Flag("Test Flag")
    var flag = URL(string: "https://google.com/")!
}

@FlagContainer
private struct DateTestFlags {
    @Flag("Test Flag")
    var flag = Date.now
}

@FlagContainer
private struct DataTestFlags {
    @Flag("Test Flag")
    var flag = Data("hello".utf8)
}

@FlagContainer(generateEquatable: false)
private struct IntTestFlags<Value> where Value: FlagValue & ExpressibleByIntegerLiteral {
    @Flag("Test flag")
    var flag: Value = 123
}

@FlagContainer(generateEquatable: false)
private struct FloatTestFlags<Value> where Value: FlagValue & ExpressibleByFloatLiteral {
    @Flag("Test flag")
    var flag: Value = 123.23
}

private struct RawRepresentableTestStruct: RawRepresentable, FlagValue, Equatable {
    var rawValue: String
}

@FlagContainer
private struct RawRepresentableTestFlags {
    @Flag("Test flag")
    var flag = RawRepresentableTestStruct(rawValue: "Test")
}

@FlagContainer
private struct OptionalValueTestFlags {
    @Flag("Test flas")
    var flag: String? = "Test"
}

@FlagContainer
private struct OptionalNoValueTestFlags {
    @Flag("Test flag")
    var flag: String?
}

@FlagContainer
private struct ArrayTestFlags {
    @Flag("Test flag")
    var flag: [Int] = [ 123, 456, 789 ]
}

@FlagContainer
private struct DictionaryTestFlags {
    @Flag("Test flag")
    var flag: [String: Int] = [ "First": 123, "Second": 456, "Third": 789 ]
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
    @Flag("Test flag")
    var flag = CodableTestStruct()
}
