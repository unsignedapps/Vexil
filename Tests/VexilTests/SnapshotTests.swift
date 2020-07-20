//
//  SnapshotTests.swift
//  Vexil: VexilTests
//
//  Created by Rob Amos on 16/7/20.
//

import Vexil
import XCTest

final class SnapshotTests: XCTestCase {

    func testSnapshotReading () {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()

        XCTAssertEqual(snapshot.topLevelFlag, false)
        XCTAssertEqual(snapshot.subgroup.secondLevelFlag, false)
        XCTAssertEqual(snapshot.subgroup.doubleSubgroup.thirdLevelFlag, false)
    }

    func testSnapshotWriting () {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()
        snapshot.topLevelFlag = true
        snapshot.subgroup.secondLevelFlag = true
        snapshot.subgroup.doubleSubgroup.thirdLevelFlag = true
        XCTAssertEqual(snapshot.topLevelFlag, true)
        XCTAssertEqual(snapshot.subgroup.secondLevelFlag, true)
        XCTAssertEqual(snapshot.subgroup.doubleSubgroup.thirdLevelFlag, true)
    }


    // MARK: - Taking Snapshots

    func testEmptySnapshot () {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        // craft a snapshot
        let source = pole.emptySnapshot()
        source.topLevelFlag = true
        source.secondTestFlag = true
        source.subgroup.secondLevelFlag = true
        source.subgroup.doubleSubgroup.thirdLevelFlag = true

        // set that as our source, and take an empty snapshot
        pole._sources = [ source ]
        let snapshot = pole.emptySnapshot()

        // everything should be reset
        XCTAssertEqual(snapshot.topLevelFlag, false)
        XCTAssertEqual(snapshot.secondTestFlag, false)
        XCTAssertEqual(snapshot.subgroup.secondLevelFlag, false)
        XCTAssertEqual(snapshot.subgroup.doubleSubgroup.thirdLevelFlag, false)
    }

    func testCurrentValueSnapshot () {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        // craft a snapshot
        let source = pole.emptySnapshot()
        source.topLevelFlag = true
        source.secondTestFlag = true
        source.subgroup.secondLevelFlag = true
        source.subgroup.doubleSubgroup.thirdLevelFlag = true

        // set that as our source, and take an normal snapshot
        pole._sources = [ source ]
        let snapshot = pole.snapshot()

        // everything should be reflect the new source
        XCTAssertEqual(snapshot.topLevelFlag, true)
        XCTAssertEqual(snapshot.secondTestFlag, true)
        XCTAssertEqual(snapshot.subgroup.secondLevelFlag, true)
        XCTAssertEqual(snapshot.subgroup.doubleSubgroup.thirdLevelFlag, true)
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
