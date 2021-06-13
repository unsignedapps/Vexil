//
//  PublisherTests.swift
//  Vexil
//
//  Created by Rob Amos on 31/7/20.
//

#if !os(Linux)

import Combine
import Vexil
import XCTest

final class PublisherTests: XCTestCase {

    // MARK: - Flag Pole Publisher

    func testPublisherSetup () {
        let expectation = self.expectation(description: "snapshot")

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var snapshots: [Snapshot<TestFlags>] = []

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                expectation.fulfill()
            }

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 1)
        XCTAssertEqual(snapshots.first?.testFlag, false)
    }

    func testPublishesSnapshotWhenAddingSource () {
        let expectation = self.expectation(description: "snapshot")
        expectation.expectedFulfillmentCount = 2

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var snapshots: [Snapshot<TestFlags>] = []

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                expectation.fulfill()
            }

        let change = pole.emptySnapshot()
        change.testFlag = true
        pole.append(snapshot: change)

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 2)
        XCTAssertEqual(snapshots.first?.testFlag, false)
        XCTAssertEqual(snapshots.last?.testFlag, true)
    }

    func testPublishesWhenSourceChanges () {
        let expectation = self.expectation(description: "published")
        expectation.expectedFulfillmentCount = 3
        let source = TestSource()
        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        var snapshots = [Snapshot<TestFlags>]()

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                expectation.fulfill()
            }

        source.subject.send([])
        source.subject.send([])

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 3)
    }

    func testPublishesWithMultipleSources () {
        let expectation = self.expectation(description: "published")
        expectation.expectedFulfillmentCount = 3

        let source1 = TestSource()
        let source2 = TestSource()

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source1, source2 ])

        var snapshots = [Snapshot<TestFlags>]()

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                expectation.fulfill()
            }

        source1.subject.send([])
        source2.subject.send([])

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 3)

    }


    // MARK: - Individual Flag Publishers

    // swiftlint:disable xct_specific_matcher

    func testIndividualFlagPublisher () {
        let expectation = self.expectation(description: "publisher")
        expectation.expectedFulfillmentCount = 2

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var values: [Bool] = []

        let cancellable = pole.$testFlag.publisher
            .sink { value in
                values.append(value)
                expectation.fulfill()
            }

        let change = pole.emptySnapshot()
        change.testFlag = true
        pole.append(snapshot: change)

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values.first, false)
        XCTAssertEqual(values.last, true)
    }


    func testIndividualFlagPublisheRemovesDuplicates () {
        let expectation = self.expectation(description: "publisher")
        expectation.expectedFulfillmentCount = 2

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var values: [Bool] = []

        let cancellable = pole.$testFlag.publisher
            .sink { value in
                values.append(value)
                expectation.fulfill()
            }

        let change = pole.emptySnapshot()
        change.testFlag = true
        pole.append(snapshot: change)
        pole.append(snapshot: change)

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values.first, false)
        XCTAssertEqual(values.last, true)
    }


    // MARK: - Setup

    func testSendsAllKeysToSourceDuringSetup () throws {

        // GIVEN a flag pole and a mock source
        let source = TestSource()
        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        // WHEN we setup a publisher (we don't actually need it, but we want it to
        // do a full setup)
        let cancellable = pole.publisher
            .sink { _ in
                // Intentionally left blank
            }

        // THEN we expect the source to have been told about all the keys
        XCTAssertEqual(
            source.requestedKeys,
            [
                "test-flag",
                "test-flag2",
                "test-flag3",
                "test-flag4"
            ]
        )
        XCTAssertNotNil(cancellable)
    }

}

// MARK: - Test Fixtures

// swiftlint:disable let_var_whitespace

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag2: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag3: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag4: Bool

}

private final class TestSource: FlagValueSource {
    var name = "Test Source"
    var subject = PassthroughSubject<Set<String>, Never>()

    var requestedKeys: Set<String> = []

    init () {}

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return nil
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
    }

    func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        self.requestedKeys = keys
        return subject.eraseToAnyPublisher()
    }

}

#endif
