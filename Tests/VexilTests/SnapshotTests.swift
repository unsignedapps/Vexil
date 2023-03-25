//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Vexil
import XCTest

final class SnapshotTests: XCTestCase {

    func testSnapshotReading() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()

        XCTAssertFalse(snapshot.topLevelFlag)
        XCTAssertFalse(snapshot.subgroup.secondLevelFlag)
        XCTAssertFalse(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)
    }

    func testSnapshotWriting() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()
        snapshot.topLevelFlag = true
        snapshot.subgroup.secondLevelFlag = true
        snapshot.subgroup.doubleSubgroup.thirdLevelFlag = true
        XCTAssertTrue(snapshot.topLevelFlag)
        XCTAssertTrue(snapshot.subgroup.secondLevelFlag)
        XCTAssertTrue(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)
    }


    // MARK: - Taking Snapshots

    func testEmptySnapshot() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        // craft a snapshot
        let source = pole.emptySnapshot()
        source.topLevelFlag = true
        source.secondTestFlag = true
        source.subgroup.secondLevelFlag = true
        source.subgroup.doubleSubgroup.thirdLevelFlag = true

        // set that as our source, and take an empty snapshot
        pole.insert(snapshot: source, at: 0)
        let snapshot = pole.emptySnapshot()

        // everything should be reset
        XCTAssertFalse(snapshot.topLevelFlag)
        XCTAssertFalse(snapshot.secondTestFlag)
        XCTAssertFalse(snapshot.subgroup.secondLevelFlag)
        XCTAssertFalse(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)
    }

    func testCurrentValueSnapshot() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        // craft a snapshot
        let source = pole.emptySnapshot()
        source.topLevelFlag = true
        source.secondTestFlag = true
        source.subgroup.secondLevelFlag = true
        source.subgroup.doubleSubgroup.thirdLevelFlag = true

        // set that as our source, and take an normal snapshot
        pole.append(snapshot: source)
        let snapshot = pole.snapshot()

        // everything should be reflect the new source
        XCTAssertTrue(snapshot.topLevelFlag)
        XCTAssertTrue(snapshot.secondTestFlag)
        XCTAssertTrue(snapshot.subgroup.secondLevelFlag)
        XCTAssertTrue(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)

        // remove it again and re-test
        pole.remove(snapshot: source)
        let empty = pole.emptySnapshot()

        // everything should be reset
        XCTAssertFalse(empty.topLevelFlag)
        XCTAssertFalse(empty.secondTestFlag)
        XCTAssertFalse(empty.subgroup.secondLevelFlag)
        XCTAssertFalse(empty.subgroup.doubleSubgroup.thirdLevelFlag)
    }

    func testCurrentSourceValueSnapshot() throws {

        // GIVEN a FlagPole and a dictionary that is not a part it
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let dictionary = FlagValueDictionary([
            "top-level-flag": .bool(true),
            "subgroup.double-subgroup.third-level-flag": .bool(true),
        ])

        // WHEN we take a snapshot of that source
        let snapshot = pole.snapshot(of: dictionary)

        // THEN we expect only the values we've changed to be true
        XCTAssertTrue(snapshot.topLevelFlag)
        XCTAssertFalse(snapshot.secondTestFlag)
        XCTAssertFalse(snapshot.subgroup.secondLevelFlag)
        XCTAssertTrue(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)

    }

}


// MARK: - Fixtures

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

private struct SubgroupFlags: FlagContainer {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

private struct DoubleSubgroupFlags: FlagContainer {

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

}
