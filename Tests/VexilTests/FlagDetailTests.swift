//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Vexil
import XCTest

final class FlagDetailTests: XCTestCase {

    func testCapturesFlagDetails() throws {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        XCTAssertEqual(pole.$topLevelFlag.key, "top-level-flag")
        XCTAssertNil(pole.$topLevelFlag.name)
        XCTAssertEqual(pole.$topLevelFlag.description, "Top level test flag")

        XCTAssertEqual(pole.$secondTestFlag.key, "second-test-flag")
        XCTAssertEqual(pole.$secondTestFlag.name, "Super Test!")
        XCTAssertEqual(pole.$secondTestFlag.description, "Second test flag")

        XCTAssertEqual(pole.subgroup.$secondLevelFlag.key, "subgroup.second-level-flag")
        XCTAssertNil(pole.subgroup.$secondLevelFlag.name)
        XCTAssertEqual(pole.subgroup.$secondLevelFlag.description, "Second Level Flag")
        XCTAssertEqual(pole.subgroup.$secondLevelFlag.displayOption, .hidden)

        XCTAssertEqual(pole.subgroup.doubleSubgroup.$thirdLevelFlag.key, "subgroup.double-subgroup.third-level-flag")
        XCTAssertEqual(pole.subgroup.doubleSubgroup.$thirdLevelFlag.name, "meow")
        XCTAssertEqual(pole.subgroup.doubleSubgroup.$thirdLevelFlag.description, "Third Level Flag")
        XCTAssertEqual(pole.subgroup.doubleSubgroup.$thirdLevelFlag.displayOption, .hidden)
    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(name: "Super Test!", default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

@FlagContainer
private struct SubgroupFlags {

    @Flag(default: false, description: "Second Level Flag", display: .hidden)
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
private struct DoubleSubgroupFlags {

    @Flag(name: "meow", default: false, description: "Third Level Flag", display: FlagDisplayOption.hidden)
    var thirdLevelFlag: Bool

}
