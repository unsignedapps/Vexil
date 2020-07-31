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

    func testPublishedSnapshotWhenAddingSource () {
        let expectation = self.expectation(description: "snapshot")

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        var snapshots: [Snapshot<TestFlags>] = []

        let cancellable = pole.publisher
            .print()
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

}

// MARK: - Test Fixtures

// swiftlint:disable let_var_whitespace

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

}

#endif
