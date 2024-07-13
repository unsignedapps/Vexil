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

final class BoxedFlagValueDecodingTests: XCTestCase {

    // MARK: - Properties and Setup

    private var decoder: JSONDecoder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .secondsSince1970
    }


    // MARK: - Boolean Flag Values

    func testBooleanTrueFlagValue() throws {
        let input = #"{"b":true}"#
        let expected = BoxedFlagValue.bool(true)

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }

    func testBooleanFalseFlagValue() {
        let input = #"{"b":false}"#
        let expected = BoxedFlagValue.bool(false)

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }


    // MARK: - String Flag Values

    func testStringFlagValue() {
        let input = #"{"s":"Test String"}"#
        let expected = BoxedFlagValue.string("Test String")

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }


    // MARK: - Data Values

    func testDataFlagValue() {
        let input = #"{"d":"VGVzdCBzdHJpbmc="}"#
        let expected = BoxedFlagValue.data(Data("Test string".utf8))

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }


    // MARK: - Number Flag Values

    func testIntFlagValue() {
        let input = #"{"i":1234}"#
        let expected = BoxedFlagValue.integer(1234)

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }


    // MARK: - Wrapping Types

    func testOptionalNoFlagValue() {
        let input = #"{"n":null}"#
        let expected = BoxedFlagValue.none

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }


    // MARK: - Collection Types

    func testArrayFlagValue() {
        let input = #"{"a":[{"i":123},{"i":456},{"i":789}]}"#
        let expected = BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ])

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }

    func testDictionaryFlagValue() {
        let input = #"{"o":{"one":{"i":123},"three":{"i":789},"two":{"i":456}}}"#
        let expected = BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])

        XCTAssertEqual(try decoder.decode(BoxedFlagValue.self, from: Data(input.utf8)), expected)
    }

}
