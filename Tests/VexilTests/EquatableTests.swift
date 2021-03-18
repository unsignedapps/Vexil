//
//  EquatableTests.swift
//  Vexil
//
//  Created by Rob Amos on 18/3/21.
//

@testable import Vexil
import XCTest

final class EquatableTests: XCTestCase {

    // MARK: - Tests

    func testSnapshotEqual() {
        let pole = FlagPole(hoist: DoubleSubgroupFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()

        XCTAssertEqual(first, second)
    }

    func testSnapshotNotEqual() {
        let pole = FlagPole(hoist: DoubleSubgroupFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()
        second.thirdLevelFlag = true

        XCTAssertNotEqual(first, second)
    }

    func testGroupEqual() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()

        XCTAssertEqual(first.subgroup, second.subgroup)
    }

    func testGroupNotEqual() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()
        second.subgroup.secondLevelFlag = true

        XCTAssertNotEqual(first.subgroup, second.subgroup)
    }

    func testGroupEqualDespiteUnrelatedChange() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        let first = pole.emptySnapshot()
        let second = pole.emptySnapshot()
        second.topLevelFlag = true

        XCTAssertEqual(first.subgroup, second.subgroup)
    }

}


// MARK: - Fixtures

private struct TestFlags: FlagContainer, Equatable {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

private struct SubgroupFlags: FlagContainer, Equatable {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

private struct DoubleSubgroupFlags: FlagContainer, Equatable {

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

}

