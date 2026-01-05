//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
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

@Suite("Flag Value Boxing", .tags(.boxing))
struct FlagValueBoxingTests {

    // MARK: - Boolean Flag Values

    @Test("Boxes boolean true")
    func booleanTrueFlagValue() {
        #expect(true.boxedFlagValue == .bool(true))
    }

    @Test("Boxes boolean false")
    func booleanFalseFlagValue() {
        #expect(false.boxedFlagValue == .bool(false))
    }


    // MARK: - String Flag Values

    @Test("Boxes string")
    func stringFlagValue() {
        #expect("Test String".boxedFlagValue == .string("Test String"))
    }

    @Test("Boxes URL")
    func urlStringFlagValue() {
        #expect(URL(string: "https://google.com/")!.boxedFlagValue == .string("https://google.com/"))
    }


    // MARK: - Data and Date Types

    @Test("Boxes data")
    func dataFlagValue() {
        #expect(Data("Test string".utf8).boxedFlagValue == .data(Data("Test string".utf8)))
    }

    @Test("Boxes date")
    func dateFlagValue() {
        let input = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]

        #expect(input.boxedFlagValue == .string(formatter.string(from: input)))
    }


    // MARK: - Integer Flag Values

    @Test("Boxes integer")
    func intFlagValue() {
        #expect(123.boxedFlagValue == .integer(123))
    }

    @Test("Boxes 8-bit integer")
    func int8FlagValue() {
        #expect(Int8(12).boxedFlagValue == .integer(12))
    }

    @Test("Boxes 16-bit integer")
    func int16FlagValue() {
        #expect(Int16(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 32-bit integer")
    func int32FlagValue() {
        #expect(Int32(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 64-bit integer")
    func int64FlagValue() {
        #expect(Int64(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes unsigned integer")
    func uintFlagValue() {
        #expect(UInt(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 8-bit unsigned integer")
    func uint8FlagValue() {
        #expect(UInt8(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 16-bit unsigned integer")
    func uint16FlagValue() {
        #expect(UInt16(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 32-bit unsigned integer")
    func uint32FlagValue() {
        #expect(UInt32(123).boxedFlagValue == .integer(123))
    }

    @Test("Boxes 64-bit unsigned integer")
    func uint64FlagValue() {
        #expect(UInt64(123).boxedFlagValue == .integer(123))
    }


    // MARK: - Floating Point Flag Values

    @Test("Boxes float")
    func floatFlagValue() {
        #expect(Float(123.456).boxedFlagValue == .float(123.456))
    }

    @Test("Boxes double")
    func doubleFlagValue() {
        #expect(123.456.boxedFlagValue == .double(123.456))
    }


    // MARK: - Wrapping Types

    @Test("Boxes raw representable")
    func rawRepresentableFlagValue() {
        #expect(TestStruct(rawValue: 123).boxedFlagValue == .integer(123))

        struct TestStruct: RawRepresentable, FlagValue, Equatable {
            let rawValue: Int
        }
    }

    @Test("Boxes optional")
    func optionalSomeFlagValue() {
        #expect(Int?.some(123)?.boxedFlagValue == .integer(123))
    }

    @Test("Boxes nil")
    func optionalNoFlagValue() {
        #expect(Int?.none.boxedFlagValue == BoxedFlagValue.none)
    }


    // MARK: - Collection Types

    @Test("Boxes array")
    func arrayFlagValue() {
        #expect([ 123, 456, 789 ].boxedFlagValue == .array([ .integer(123), .integer(456), .integer(789) ]))
    }

    @Test("Boxes dictionary")
    func dictionaryFlagValue() {
        #expect(
            [ "one": 123, "two": 456, "three": 789 ].boxedFlagValue
                == .dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])
        )
    }


    // MARK: - Codable Types

    @Test("Boxes codable", .tags(.codable))
    func codableFlagValue() throws {
        let input = TestStruct()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let expected = try encoder.encode(Wrapper(wrapped: input))

        #expect(input.boxedFlagValue == .data(expected))

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
