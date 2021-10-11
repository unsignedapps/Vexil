//
//  FlagValueDitionaryTests.swift
//  Vexil
//
//  Created by Rob Amos on 17/8/20.
//

@testable import Vexil
import XCTest

final class FlagValueDictionaryTests: XCTestCase {

    // MARK: - Reading Values

    func testReadsValues () {
        let source: FlagValueDictionary = [
            "top-level-flag": .bool(true)
        ]

        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
        XCTAssertTrue(flagPole.topLevelFlag)
        XCTAssertFalse(flagPole.oneFlagGroup.secondLevelFlag)
    }


    // MARK: - Writing Values

    func testWritesValues () {
        AssertNoThrow {
            let source = FlagValueDictionary()
            let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])

            let snapshot = flagPole.emptySnapshot()
            snapshot.topLevelFlag = true
            snapshot.oneFlagGroup.secondLevelFlag = false
            try flagPole.save(snapshot: snapshot, to: source)

            XCTAssertEqual(source.storage["top-level-flag"], .bool(true))
            XCTAssertEqual(source.storage["one-flag-group.second-level-flag"], .bool(false))
        }
    }


    // MARK: - Publishing Tests

    #if !os(Linux)

    func testPublishesValues () {
        let expectation = self.expectation(description: "publisher")
        expectation.expectedFulfillmentCount = 3

        let source = FlagValueDictionary()
        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        var snapshots = [Snapshot<TestFlags>]()
        let cancellable = flagPole.publisher
            .sink { snapshot in
                snapshots.append(snapshot)
                expectation.fulfill()
            }

        source["top-level-flag"] = .bool(true)
        source["one-flag-group.second-level-flag"] = .bool(true)

        self.wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 3)
        XCTAssertEqual(snapshots[safe: 0]?.topLevelFlag, false)
        XCTAssertEqual(snapshots[safe: 0]?.oneFlagGroup.secondLevelFlag, false)
        XCTAssertEqual(snapshots[safe: 1]?.topLevelFlag, true)
        XCTAssertEqual(snapshots[safe: 1]?.oneFlagGroup.secondLevelFlag, false)
        XCTAssertEqual(snapshots[safe: 2]?.topLevelFlag, true)
        XCTAssertEqual(snapshots[safe: 2]?.oneFlagGroup.secondLevelFlag, true)
    }

    #endif

}


// MARK: - Fixtures

// swiftlint:disable let_var_whitespace

private struct TestFlags: FlagContainer {

    @FlagGroup(description: "Test 1")
    var oneFlagGroup: OneFlags

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

}

private struct OneFlags: FlagContainer {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool
}
