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

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var snapshots: [Snapshot<TestFlags>] = []

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                if snapshots.count == 2 {
                    expectation.fulfill()
                }
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
        let source = TestSource()
        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        var snapshots = [Snapshot<TestFlags>]()

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                if snapshots.count == 3 {
                    expectation.fulfill()
                }
            }

        source.subject.send()
        source.subject.send()

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 3)
    }

    func testPublishesWithMultipleSources () {
        let expectation = self.expectation(description: "published")

        let source1 = TestSource()
        let source2 = TestSource()

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source1, source2 ])

        var snapshots = [Snapshot<TestFlags>]()

        let cancellable = pole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                if snapshots.count == 3 {
                    expectation.fulfill()
                }
            }

        source1.subject.send()
        source2.subject.send()

        wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 3)

    }


    // MARK: - Individual Flag Publishers

    // swiftlint:disable xct_specific_matcher

    func testIndividualFlagPublisher () {
        let expectation = self.expectation(description: "publisher")

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var values: [Bool] = []

        let cancellable = pole.$testFlag.publisher
            .sink { value in
                values.append(value)
                if values.count == 2 {
                    expectation.fulfill()
                }
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

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var values: [Bool] = []

        let cancellable = pole.$testFlag.publisher
            .sink { value in
                values.append(value)
                if values.count == 2 {
                    expectation.fulfill()
                }
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

}

// MARK: - Test Fixtures

// swiftlint:disable let_var_whitespace

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

}

private final class TestSource: FlagValueSource {
    var name = "Test Source"
    var subject = PassthroughSubject<Void, Never>()

    init () {}

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return nil
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
    }

    var valuesDidChange: AnyPublisher<Void, Never>? {
        return subject.eraseToAnyPublisher()
    }
}

#endif
