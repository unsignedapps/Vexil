//
//  BoxedFlagValueEncodingTests.swift
//  Vexil
//
//  Created by Rob Amos on 11/10/2021.
//

@testable import Vexil
import XCTest

final class BoxedFlagValueEncodingTests: XCTestCase {

    // MARK: - Properties and Setup

    private var encoder: JSONEncoder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [ .sortedKeys ]
        self.encoder.dataEncodingStrategy = .base64
        self.encoder.dateEncodingStrategy = .secondsSince1970
    }


    // MARK: - Boolean Flag Values

    func testBooleanTrueFlagValue () throws {
        let input = BoxedFlagValue.bool(true)
        let expected = #"{"b":true}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }

    func testBooleanFalseFlagValue () {
        let input = BoxedFlagValue.bool(false)
        let expected = #"{"b":false}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }


    // MARK: - String Flag Values

    func testStringFlagValue () {
        let input = BoxedFlagValue.string("Test String")
        let expected = #"{"s":"Test String"}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }


    // MARK: - Data Values

    func testDataFlagValue () {
        let input = BoxedFlagValue.data(Data("Test string".utf8))
        let expected = #"{"d":"VGVzdCBzdHJpbmc="}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }


    // MARK: - Number Flag Values

    func testIntFlagValue () {
        let input = BoxedFlagValue.integer(1234)
        let expected = #"{"i":1234}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }


    // MARK: - Wrapping Types

    func testOptionalNoFlagValue () {
        let input = BoxedFlagValue.none
        let expected = #"{"n":null}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }


    // MARK: - Collection Types

    func testArrayFlagValue () {
        let input = BoxedFlagValue.array([ .integer(123), .integer(456), .integer(789) ])
        let expected = #"{"a":[{"i":123},{"i":456},{"i":789}]}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }

    func testDictionaryFlagValue () {
        let input = BoxedFlagValue.dictionary([ "one": .integer(123), "two": .integer(456), "three": .integer(789) ])
        let expected = #"{"o":{"one":{"i":123},"three":{"i":789},"two":{"i":456}}}"#

        XCTAssertEqual(try self.encoder.encode(input), Data(expected.utf8))
    }

}
