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
        let snapshot = pole.snapshot()
        XCTAssertEqual(snapshot.topLevelFlag, false)
        XCTAssertEqual(snapshot.subgroup.secondLevelFlag, false)
    }

    func testSnapshotWriting () {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        var snapshot = pole.snapshot()
        snapshot.topLevelFlag = true
        XCTAssertEqual(snapshot.topLevelFlag, true)
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

}
