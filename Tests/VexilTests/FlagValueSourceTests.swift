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

import Vexil
import XCTest

final class FlagValueSourceTests: XCTestCase {

    func testSourceIsChecked() {
        var accessedKeys = [String]()
        let values = [
            "test-flag": true,
            "second-test-flag": false,
        ]

        let source = TestGetSource(values: values) {
            accessedKeys.append($0)
        }

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        // test the source has the right values, this triggers the subject above
        XCTAssertFalse(pole.secondTestFlag)
        XCTAssertTrue(pole.testFlag)

        XCTAssertEqual(accessedKeys.count, 2)
        XCTAssertEqual(accessedKeys.first, "second-test-flag")
        XCTAssertEqual(accessedKeys.last, "test-flag")
    }

    func testSourceSets() throws {
        var events = [TestSetSource.Event]()
        let source = TestSetSource {
            events.append($0)
        }

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        let snapshot = pole.emptySnapshot()
        snapshot.secondTestFlag = false
        snapshot.testFlag = true

        try pole.save(snapshot: snapshot, to: source)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.0, "test-flag")
        XCTAssertEqual(events.first?.1, true)
        XCTAssertEqual(events.last?.0, "second-test-flag")
        XCTAssertEqual(events.last?.1, false)
    }

    func testSourceCopies() throws {

        // GIVEN two dictionaries
        let source = FlagValueDictionary([
            "test-flag": .bool(true),
            "subgroup.test-flag": .bool(true),
        ])
        let destination = FlagValueDictionary()

        // WHEN we copy from the source to the destination
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        try pole.copyFlagValues(from: source, to: destination)

        // THEN we expect those two dictionaries to match
        XCTAssertEqual(destination.count, 2)
        XCTAssertEqual(destination["test-flag"], .bool(true))
        XCTAssertEqual(destination["subgroup.test-flag"], .bool(true))

    }

    func testSourceRemovesAllVales() throws {

        // GIVEN a dictionary with some values
        let source = FlagValueDictionary([
            "test-flag": .bool(true),
            "subgroup.test-flag": .bool(true),
        ])

        // WHEN we remove all values from that source
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        try pole.removeFlagValues(in: source)

        // THEN the source should now be empty
        XCTAssertTrue(source.isEmpty)

    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

    @Flag(default: true, description: "This is another test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "A test subgroup")
    var subgroup: Subgroup
}

@FlagContainer
private struct Subgroup {

    @Flag(default: false, description: "A test flag in a subgroup")
    var testFlag: Bool

}

private final class TestGetSource: FlagValueSource {

    let name = "Test Source"
    var subject: (String) -> Void
    var values: [String: Bool]

    init(values: [String: Bool], subject: @escaping (String) -> Void) {
        self.values = values
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        subject(key)
        return values[key] as? Value
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {}

}


private final class TestSetSource: FlagValueSource {

    typealias Event = (String, Bool)

    let name = "Test Source"
    var subject: (Event) -> Void

    init(subject: @escaping (Event) -> Void) {
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        nil
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        guard let value = value as? Bool else {
            return
        }
        subject((key, value))
    }

}
