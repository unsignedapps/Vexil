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

import Testing
import Vexil

@Suite("Flag Details")
struct FlagDetailTests {

    @Test("Captures details")
    func capturesFlagDetails() throws {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        #expect(pole.$topLevelFlag.key == "top-level-flag")
        #expect(pole.$topLevelFlag.name == "Top Level Flag")
        #expect(pole.$topLevelFlag.description == "Top level test flag")

        #expect(pole.$secondTestFlag.key == "second-test-flag")
        #expect(pole.$secondTestFlag.name == "Super Test!")
        #expect(pole.$secondTestFlag.description == "Second test flag")

        #expect(pole.subgroup.$secondLevelFlag.key == "subgroup.second-level-flag")
        #expect(pole.subgroup.$secondLevelFlag.name == "Second Level Flag")
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

    @Flag(name: "Super Test!", description: "Second test flag")
    var secondTestFlag = false

    @FlagGroup("Subgroup of test flags")
    var subgroup: SubgroupFlags

}

@FlagContainer
private struct SubgroupFlags {

    @Flag(description: "Second Level Flag", display: .hidden)
    var secondLevelFlag = false

    @FlagGroup("Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
private struct DoubleSubgroupFlags {

    @Flag(name: "meow", description: "Third Level Flag", display: FlagDisplayOption.hidden)
    var thirdLevelFlag = false

}
