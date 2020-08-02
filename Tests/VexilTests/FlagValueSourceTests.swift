//
//  FlagValueSourceTests.swift
//  Vexil
//
//  Created by Rob Amos on 2/8/20.
//

import Vexil
import XCTest

final class FlagValueSourceTests: XCTestCase {

    func testSourceIsChecked () {
        var accessedKeys = [String]()
        let values = [
            "test-flag": true,
            "second-test-flag": false
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

    func testSourceSets () {
        AssertNoThrow {
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
    }
}


// MARK: - Fixtures

// swiftlint:disable let_var_whitespace

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

    @Flag(default: true, description: "This is another test flag")
    var secondTestFlag: Bool

}

private final class TestGetSource: FlagValueSource {

    let name = "Test Source"
    var subject: (String) -> Void
    var values: [String: Bool]

    init (values: [String: Bool], subject: @escaping (String) -> Void) {
        self.values = values
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        self.subject(key)
        return self.values[key] as? Value
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
    }

}


private final class TestSetSource: FlagValueSource {

    typealias Event = (String, Bool)

    let name = "Test Source"
    var subject: (Event) -> Void

    init (subject: @escaping (Event) -> Void) {
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return nil
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        guard let value = value as? Bool else { return }
        self.subject((key, value))
    }

}
