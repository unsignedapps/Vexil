//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Testing
import Vexil

@Suite("Snapshots", .tags(.pole, .snapshot))
struct SnapshotTests {

    @Test("Reads from snapshot")
    func snapshotReading() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()

        #expect(snapshot.topLevelFlag == false)
        #expect(snapshot.subgroup.secondLevelFlag == false)
        #expect(snapshot.subgroup.doubleSubgroup.thirdLevelFlag == false)
    }

    @Test("Writes to snapshot")
    func snapshotWriting() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let snapshot = pole.emptySnapshot()
        snapshot.topLevelFlag = true
        snapshot.subgroup.secondLevelFlag = true
        snapshot.subgroup.doubleSubgroup.thirdLevelFlag = true
        #expect(snapshot.topLevelFlag)
        #expect(snapshot.subgroup.secondLevelFlag)
        #expect(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)
    }


    // MARK: - Taking Snapshots

    @Test("Takes empty snapshot")
    func emptySnapshot() {
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
        #expect(snapshot.topLevelFlag == false)
        #expect(snapshot.secondTestFlag == false)
        #expect(snapshot.subgroup.secondLevelFlag == false)
        #expect(snapshot.subgroup.doubleSubgroup.thirdLevelFlag == false)
    }

    @Test("Snapshots reflect current sources")
    func currentSources() {
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
        #expect(snapshot.topLevelFlag)
        #expect(snapshot.secondTestFlag)
        #expect(snapshot.subgroup.secondLevelFlag)
        #expect(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)

        // remove it again and re-test
        pole.remove(snapshot: source)
        let empty = pole.snapshot()

        // everything should be reset
        #expect(empty.topLevelFlag == false)
        #expect(empty.secondTestFlag == false)
        #expect(empty.subgroup.secondLevelFlag == false)
        #expect(empty.subgroup.doubleSubgroup.thirdLevelFlag == false)
    }

    @Test("Snapshots specific source", .tags(.dictionary))
    func specificSource() throws {

        // GIVEN a FlagPole and a dictionary that is not a part it
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let dictionary = FlagValueDictionary([
            "top-level-flag": .bool(true),
            "subgroup.double-subgroup.third-level-flag": .bool(true),
        ])

        // WHEN we take a snapshot of that source
        let snapshot = pole.snapshot(of: dictionary)

        // THEN we expect only the values we've changed to be true
        #expect(snapshot.topLevelFlag)
        #expect(snapshot.secondTestFlag == false)
        #expect(snapshot.subgroup.secondLevelFlag == false)
        #expect(snapshot.subgroup.doubleSubgroup.thirdLevelFlag)

    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag("Top level test flag")
    var topLevelFlag = false

    @Flag("Second test flag")
    var secondTestFlag = false

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

@FlagContainer
private struct SubgroupFlags {

    @Flag("Second level test flag")
    var secondLevelFlag = false

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
private struct DoubleSubgroupFlags {

    @Flag("Third level test flag")
    var thirdLevelFlag = false

}
