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

import Testing
import Vexil

#if compiler(<6)

import XCTest

final class FlagDetailTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(FlagDetailTests.self, hostedBy: self)
    }
}

#endif

@Suite("Flag Details")
struct FlagDetailTests {

    @Test("Captures details")
    func capturesFlagDetails() throws {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        #expect(pole.$topLevelFlag.key == "top-level-flag")
        #expect(pole.$topLevelFlag.name == nil)
        #expect(pole.$topLevelFlag.description == "Top level test flag")

        #expect(pole.$secondTestFlag.key == "second-test-flag")
        #expect(pole.$secondTestFlag.name == "Super Test!")
        #expect(pole.$secondTestFlag.description == "Second test flag")

        #expect(pole.subgroup.$secondLevelFlag.key == "subgroup.second-level-flag")
        #expect(pole.subgroup.$secondLevelFlag.name == nil)
        #expect(pole.subgroup.$secondLevelFlag.description == "Second Level Flag")
        #expect(pole.subgroup.$secondLevelFlag.displayOption == .hidden)

        #expect(pole.subgroup.doubleSubgroup.$thirdLevelFlag.key == "subgroup.double-subgroup.third-level-flag")
        #expect(pole.subgroup.doubleSubgroup.$thirdLevelFlag.name == "meow")
        #expect(pole.subgroup.doubleSubgroup.$thirdLevelFlag.description == "Third Level Flag")
        #expect(pole.subgroup.doubleSubgroup.$thirdLevelFlag.displayOption == .hidden)
    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag("Top level test flag")
    var topLevelFlag = false

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
