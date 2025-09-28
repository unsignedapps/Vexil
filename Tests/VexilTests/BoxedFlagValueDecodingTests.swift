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

@Suite("BoxedFlagValue decoding", .tags(.boxing, .codable))
struct BoxedFlagValueDecodingTests {

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()


    // MARK: - Boolean Flag Values

    @Test("Decodes boolean true")
    func booleanTrueFlagValue() throws {
        let input = #"{"b":true}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .bool(true))
    }

    @Test("Decodes boolean false")
    func booleanFalseFlagValue() throws {
        let input = #"{"b":false}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .bool(false))
    }


    // MARK: - String Flag Values

    @Test("Decodes string")
    func stringFlagValue() throws {
        let input = #"{"s":"Test String"}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .string("Test String"))
    }


    // MARK: - Data Values

    @Test("Decodes data")
    func dataFlagValue() throws {
        let input = #"{"d":"VGVzdCBzdHJpbmc="}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .data(Data("Test string".utf8)))
    }


    // MARK: - Number Flag Values

    @Test("Decodes integer")
    func intFlagValue() throws {
        let input = #"{"i":1234}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .integer(1234))
    }

    @Test("Decodes double")
    func doubleFlagValue() throws {
        let input = #"{"r":123.456}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .double(123.456))
    }

    @Test("Decodes float")
    func floatFlagValue() throws {
        let input = #"{"f":123.456}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .float(123.456))
    }


    // MARK: - Wrapping Types

    @Test("Decodes nil")
    func optionalNoFlagValue() throws {
        let input = #"{"n":null}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .none)
    }


    // MARK: - Collection Types

    @Test("Decodes array")
    func arrayFlagValue() throws {
        let input = #"{"a":[{"i":123},{"i":456},{"i":789}]}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .array([ .integer(123), .integer(456), .integer(789) ]))
    }

    @Test("Decodes dictionary")
    func dictionaryFlagValue() throws {
        let input = #"{"o":{"one":{"i":123},"three":{"i":789},"two":{"i":456}}}"#.utf8
        let decoded = try decoder.decode(BoxedFlagValue.self, from: Data(input))
        #expect(decoded == .dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ]))
    }

}
