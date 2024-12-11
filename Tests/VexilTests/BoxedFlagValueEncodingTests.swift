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

@Suite("BoxedFlagValue encoding", .tags(.boxing, .codable))
struct BoxedFlagValueEncodingTests {

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [ .sortedKeys ]
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()


    // MARK: - Boolean Flag Values

    @Test("Encodes boolean true")
    func booleanTrueFlagValue() throws {
        let input = BoxedFlagValue.bool(true)
        let expected = #"{"b":true}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }

    @Test("Encodes boolean false")
    func booleanFalseFlagValue() throws {
        let input = BoxedFlagValue.bool(false)
        let expected = #"{"b":false}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }


    // MARK: - String Flag Values

    @Test("Encodes string")
    func stringFlagValue() throws {
        let input = BoxedFlagValue.string("Test String")
        let expected = #"{"s":"Test String"}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }


    // MARK: - Data Values

    @Test("Encodes data")
    func dataFlagValue() throws {
        let input = BoxedFlagValue.data(Data("Test string".utf8))
        let expected = #"{"d":"VGVzdCBzdHJpbmc="}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }


    // MARK: - Number Flag Values

    @Test("Encodes integer")
    func intFlagValue() throws {
        let input = BoxedFlagValue.integer(1234)
        let expected = #"{"i":1234}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }

    @Test("Encodes double")
    func doubleFlagValue() throws {
        let input = BoxedFlagValue.double(123.456)
        let expected = #"{"r":123.456}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }

    @Test("Encodes float")
    func floatFlagValue() throws {
        let input = BoxedFlagValue.float(123.456)
        let expected = #"{"f":123.456}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }


    // MARK: - Wrapping Types

    @Test("Encodes nil")
    func optionalNoFlagValue() throws {
        let input = BoxedFlagValue.none
        let expected = #"{"n":null}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }


    // MARK: - Collection Types

    @Test("Encodes array")
    func arrayFlagValue() throws {
        let input = BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ])
        let expected = #"{"a":[{"i":123},{"i":456},{"i":789}]}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }

    @Test("Encodes dictionary")
    func dictionaryFlagValue() throws {
        let input = BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])
        let expected = #"{"o":{"one":{"i":123},"three":{"i":789},"two":{"i":456}}}"#.utf8
        let encoded = try encoder.encode(input)
        #expect(encoded == Data(expected))
    }

}
