//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if !os(Linux)
import Combine
#endif

import Testing
@testable import Vexil

@Suite("Equatable Tests", .tags(.pole))
struct EquatableTests {

    // MARK: - Tests

    @Test("Subsequent snapshots are equal", .tags(.snapshot))
    func snapshotEqual() {
        let pole = FlagPole(hoist: DoubleSubgroupFlags.self, sources: [])
        #expect(pole.emptySnapshot() == pole.emptySnapshot())
    }

    @Test("Snapshots with different contents are not equal", .tags(.snapshot))
    func snapshotNotEqual() {
        let pole = FlagPole(hoist: DoubleSubgroupFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()
        second.thirdLevelFlag = true
        #expect(first != second)
    }

    @Test("Computed flag groups are equal")
    func groupEquality() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        #expect(pole.subgroup == pole.subgroup)
    }

    @Test("Computed flags are equal")
    func flagEquality() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        #expect(pole.topLevelFlag == pole.topLevelFlag)
    }

    // MARK: - Publisher-based Tests

    // #if !os(Linux)
//
//    // swiftlint:disable:next function_body_length
//    func testPublisherEmitsEquatableElements() throws {
//        throw XCTSkip("Temporarily disabled until we can make it more reliable")
//
//        // GIVEN an empty dictionary and flag pole
//        let dictionary = FlagValueDictionary()
//        let pole = FlagPole(hoist: TestFlags.self, sources: [ dictionary ])
//
//        var allSnapshots: [Snapshot<TestFlags>] = []
//        var firstFilter: [Snapshot<TestFlags>] = []
//        var secondFilter: [Snapshot<TestFlags>] = []
//        var thirdFilter: [Snapshot<TestFlags>] = []
//        let expectation = expectation(description: "snapshot")
//
//        let cancellable = pole.snapshotPublisher
//            .handleEvents(receiveOutput: {
//                print($0.values.withLock { $0 })
//                allSnapshots.append($0)
//            })
//            .removeDuplicates()
//            .handleEvents(receiveOutput: {
//                firstFilter.append($0)
//            })
//            .removeDuplicates(by: { $0.subgroup == $1.subgroup })
//            .handleEvents(receiveOutput: {
//                secondFilter.append($0)
//            })
//            .removeDuplicates(by: { $0.subgroup.doubleSubgroup == $1.subgroup.doubleSubgroup })
//            .handleEvents(receiveOutput: {
//                thirdFilter.append($0)
//            })
//            .print()
//            .sink { _ in
//                if allSnapshots.count == 6 {
//                    expectation.fulfill()
//                }
//            }
//
//        // WHEN we emit, then change some values and emit more
//        dictionary["untracked-key"] = .bool(true)                              // 1
//        dictionary["top-level-flag"] = .bool(true)                             // 2
//        dictionary["second-test-flag"] = .bool(true)                           // 3
//        dictionary["subgroup.second-level-flag"] = .bool(true)                 // 4
//        dictionary["subgroup.double-subgroup.third-level-flag"] = .bool(true)  // 5
//
//        // THEN we should have 6 snapshots of varying equatability
//        wait(for: [ expectation ], timeout: 1.0)
//
//        XCTAssertNotNil(cancellable)
//
//        // 1. Two shapshots should be fully Equatable if we change an untracked key
//        XCTAssertEqual(allSnapshots[safe: 0], allSnapshots[safe: 1])
//
//        // 2. Two snapshots are not Equatable, but their subgroup is when we change a top-level flag
//        XCTAssertNotNil(allSnapshots[safe: 2])
//        XCTAssertNotEqual(allSnapshots[safe: 0], allSnapshots[safe: 2])
//        XCTAssertEqual(allSnapshots[safe: 0]?.subgroup, allSnapshots[safe: 2]?.subgroup)
//
//        // 3. Two snapshots are not Equatable but their subgroup still is when we change a different top-level flag
//        //    It should also not be equal to the snapshot from test #2
//        XCTAssertNotNil(allSnapshots[safe: 3])
//        XCTAssertNotEqual(allSnapshots[safe: 0], allSnapshots[safe: 3])
//        XCTAssertNotEqual(allSnapshots[safe: 2], allSnapshots[safe: 3])
//        XCTAssertEqual(allSnapshots[safe: 0]?.subgroup, allSnapshots[safe: 3]?.subgroup)
//
//        // 4. Two snapshots should not be equal, and neither should their subgroups, when we change a flag in the subgroup
//        XCTAssertNotNil(allSnapshots[safe: 4])
//        XCTAssertNotEqual(allSnapshots[safe: 0], allSnapshots[safe: 4])
//        XCTAssertNotEqual(allSnapshots[safe: 0]?.subgroup, allSnapshots[safe: 4]?.subgroup)
//        XCTAssertEqual(allSnapshots[safe: 0]?.subgroup.doubleSubgroup, allSnapshots[safe: 4]?.subgroup.doubleSubgroup)
//
//        // 5. Two snapshots are never equal when we change a flag so that all parts of the tree are mutated
//        XCTAssertNotNil(allSnapshots[safe: 5])
//        XCTAssertNotEqual(allSnapshots[safe: 0], allSnapshots[safe: 5])
//        XCTAssertNotEqual(allSnapshots[safe: 0]?.subgroup, allSnapshots[safe: 5]?.subgroup)
//        XCTAssertNotEqual(allSnapshots[safe: 0]?.subgroup.doubleSubgroup, allSnapshots[safe: 5]?.subgroup.doubleSubgroup)
//
//        // AND we expect those to have been filtered appropriately
//        XCTAssertEqual(allSnapshots.count, 6)
//        XCTAssertEqual(firstFilter.count, 5)            // dropped the first change
//        XCTAssertEqual(secondFilter.count, 3)           // dropped 1, 2 and 3
//        XCTAssertEqual(thirdFilter.count, 2)            // dropped everything except 5
//
//    }
//
    // #endif
}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag("Top level test flag")
    var topLevelFlag = false

    @Flag("Second test flag")
    var secondTestFlag = false

    @FlagGroup("Subgroup of test flags")
    var subgroup: SubgroupFlags

}

@FlagContainer
private struct SubgroupFlags {

    @Flag("Second level test flag")
    var secondLevelFlag = false

    @FlagGroup("Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
private struct DoubleSubgroupFlags {

    @Flag("Third level test flag")
    var thirdLevelFlag = false

}
