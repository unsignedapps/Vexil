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

@Suite("Flag Value Unboxing", .tags(.boxing))
struct FlagValueUnboxingTests {

    // MARK: - Boolean Flag Values

    @Test("Unboxes boolean", arguments: zip(
        [ BoxedFlagValue.bool(true), .bool(false), .none ],
        [ true, false, nil ]
    ))
    func booleanFlagValues(boxed: BoxedFlagValue, unboxed: Bool?) {
        #expect(Bool(boxedFlagValue: boxed) == unboxed)
    }


    // MARK: - String Flag Values

    @Test("Unboxes string", arguments: zip(
        [ BoxedFlagValue.string("Test String"), .none ],
        [ "Test String", nil ]
    ))
    func stringFlagValues(boxed: BoxedFlagValue, unboxed: String?) {
        #expect(String(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes URL", arguments: zip(
        [ BoxedFlagValue.string("https://google.com/"), .none ],
        [ URL(string: "https://google.com/")!, nil ]
    ))
    func urlStringFlagValues(boxed: BoxedFlagValue, unboxed: URL?) {
        #expect(URL(boxedFlagValue: boxed) == unboxed)
    }


    // MARK: - Data and Date Types

    @Test("Unboxes data", arguments: zip(
        [ BoxedFlagValue.data(Data("Test string".utf8)), .none ],
        [ Data("Test string".utf8), nil ]
    ))
    func dataFlagValues(boxed: BoxedFlagValue, unboxed: Data?) {
        #expect(Data(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes date")
    func dateFlagValues() throws {
        let expected = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
        let boxed = BoxedFlagValue.string(formatter.string(from: expected))

        let calendar = Calendar(identifier: .gregorian)
        guard let date = Date(boxedFlagValue: boxed) else {
            throw Error.couldNotUnboxDate
        }

        #expect(calendar.compare(expected, to: date, toGranularity: .second) == .orderedSame)
        #expect(Date(boxedFlagValue: .none) == nil)

        enum Error: Swift.Error {
            case couldNotUnboxDate
        }
    }


    // MARK: - Integer Flag Values

    @Test("Unboxes integer", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ 123, nil ]
    ))
    func intFlagValues(boxed: BoxedFlagValue, unboxed: Int?) {
        #expect(Int(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 8-bit integer", arguments: zip(
        [ BoxedFlagValue.integer(12), .none ],
        [ 12, nil ]
    ))
    func int8FlagValues(boxed: BoxedFlagValue, unboxed: Int8?) {
        #expect(Int8(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 16-bit integer", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ 123, nil ]
    ))
    func int16FlagValues(boxed: BoxedFlagValue, unboxed: Int16?) {
        #expect(Int16(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 32-bit integer", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ 123, nil ]
    ))
    func int32FlagValues(boxed: BoxedFlagValue, unboxed: Int32?) {
        #expect(Int32(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 64-bit integer", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ 123, nil ]
    ))
    func int64FlagValues(boxed: BoxedFlagValue, unboxed: Int64?) {
        #expect(Int64(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes unsigned integer", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ 123, nil ]
    ))
    func uintFlagValues(boxed: BoxedFlagValue, unboxed: UInt?) {
        #expect(UInt(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 8-bit unsigned integer", arguments: zip(
        [ BoxedFlagValue.integer(12), .none ],
        [ 12, nil ]
    ))
    func uint8FlagValues(boxed: BoxedFlagValue, unboxed: UInt8?) {
        #expect(UInt8(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 16-bit unsigned integer", arguments: zip(
        [ BoxedFlagValue.integer(12), .none ],
        [ 12, nil ]
    ))
    func uint16FlagValues(boxed: BoxedFlagValue, unboxed: UInt16?) {
        #expect(UInt16(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 32-bit unsigned integer", arguments: zip(
        [ BoxedFlagValue.integer(12), .none ],
        [ 12, nil ]
    ))
    func uint32FlagValues(boxed: BoxedFlagValue, unboxed: UInt32?) {
        #expect(UInt32(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes 64-bit unsigned integer", arguments: zip(
        [ BoxedFlagValue.integer(12), .none ],
        [ 12, nil ]
    ))
    func uint64FlagValues(boxed: BoxedFlagValue, unboxed: UInt64?) {
        #expect(UInt64(boxedFlagValue: boxed) == unboxed)
    }


    // MARK: - Floating Point Flag Values

    @Test("Unboxes float", arguments: zip(
        [ BoxedFlagValue.float(123.456), .double(123.456), .none ],
        [ 123.456, 123.456, nil ]
    ))
    func floatFlagValues(boxed: BoxedFlagValue, unboxed: Float?) {
        #expect(Float(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes double", arguments: zip(
        [ BoxedFlagValue.double(123.456), .none ],
        [ 123.456, nil ]
    ))
    func doubleFlagValues(boxed: BoxedFlagValue, unboxed: Double?) {
        #expect(Double(boxedFlagValue: boxed) == unboxed)
    }


    // MARK: - Wrapping Types

    @Test("Unboxes raw representable", arguments: zip(
        [ BoxedFlagValue.integer(123), .none ],
        [ TestRawRepresentable(rawValue: 123), nil ]
    ))
    private func rawRepresentableFlagValue(boxed: BoxedFlagValue, unboxed: TestRawRepresentable?) {
        #expect(TestRawRepresentable(boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes optional")
    func optionalFlagValues() {
        #expect(Int?(boxedFlagValue: .integer(123)) == Int?.some(123))
        #expect(Int?(boxedFlagValue: .none) == Int?.none)
    }


    // MARK: - Collection Types

    @Test("Unboxes array", arguments: zip(
        [ BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ]), .none ],
        [ [ 123, 456, 789 ], nil ]
    ))
    func arrayFlagValues(boxed: BoxedFlagValue, unboxed: [Int]?) {
        #expect([Int](boxedFlagValue: boxed) == unboxed)
    }

    @Test("Unboxes dictionary", arguments: zip(
        [ BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ]), .none ],
        [ [ "one": 123, "two": 456, "three": 789 ], nil ]
    ))
    func dictionaryFlagValues(boxed: BoxedFlagValue, unboxed: [String: Int]?) {
        #expect([String: Int](boxedFlagValue: boxed) == unboxed)
    }


    // MARK: - Codable Types

    @Test("Unboxes codable")
    private func testCodableFlagValue() throws {
        let expected = TestCodable()
        let data = try JSONEncoder().encode(Wrapper(wrapped: expected))

        #expect(TestCodable(boxedFlagValue: .data(data)) == expected)
        #expect(TestCodable(boxedFlagValue: .none) == nil)
    }
}

// MARK: - Fixtures

private struct TestRawRepresentable: RawRepresentable, FlagValue, Equatable {
    let rawValue: Int
}

private struct TestCodable: Codable, FlagValue, Equatable {
    let property1: Int
    let property2: String
    let property3: Double

    init() {
        self.property1 = 123
        self.property2 = "456"
        self.property3 = 789.0
    }
}
