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

@Suite("Key Encoding", .tags(.pole))
struct KeyEncodingTests {

    @Test("Encodes with kebab-case")
    func kebabcase() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: nil, separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        #expect(pole.$topLevelFlag.key == "top-level-flag")
        #expect(pole.oneFlagGroup.$secondLevelFlag.key == "one-flag-group.second-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key == "one-flag-group.two.third-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key == "one-flag-group.two.third-level-flag2")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key == "one-flag-group.two.customKey")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key == "customKeyPath")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key == "one-flag-group.two.standard")
    }

    @Test("Encodes with snake_case")
    func snakecase() {
        let config = VexilConfiguration(codingPathStrategy: .snakecase, prefix: nil, separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        #expect(pole.$topLevelFlag.key == "top_level_flag")
        #expect(pole.oneFlagGroup.$secondLevelFlag.key == "one_flag_group.second_level_flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key == "one_flag_group.two.third_level_flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key == "one_flag_group.two.third_level_flag2")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key == "one_flag_group.two.customKey")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key == "customKeyPath")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key == "one_flag_group.two.standard")
    }

    @Test("Encodes with prefix")
    func prefix() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: "prefix", separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        #expect(pole.$topLevelFlag.key == "prefix.top-level-flag")
        #expect(pole.oneFlagGroup.$secondLevelFlag.key == "prefix.one-flag-group.second-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key == "prefix.one-flag-group.two.third-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key == "prefix.one-flag-group.two.third-level-flag2")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key == "prefix.one-flag-group.two.customKey")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key == "customKeyPath")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key == "prefix.one-flag-group.two.standard")
    }

    @Test("Encodes with custom separator")
    func customSeparator() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: "prefix", separator: "/")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        #expect(pole.$topLevelFlag.key == "prefix/top-level-flag")
        #expect(pole.oneFlagGroup.$secondLevelFlag.key == "prefix/one-flag-group/second-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key == "prefix/one-flag-group/two/third-level-flag")
        #expect(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key == "prefix/one-flag-group/two/third-level-flag2")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key == "prefix/one-flag-group/two/customKey")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key == "customKeyPath")
        #expect(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key == "prefix/one-flag-group/two/standard")
    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @FlagGroup(description: "Test 1")
    var oneFlagGroup: OneFlags

    @Flag("Top level test flag")
    var topLevelFlag = false

}

@FlagContainer
private struct OneFlags {

    @FlagGroup(keyStrategy: .customKey("two"), description: "Test Two")
    var twoFlagGroup: TwoFlags

    @Flag("Second level test flag")
    var secondLevelFlag = false
}

@FlagContainer
private struct TwoFlags {

    @FlagGroup(keyStrategy: .skip, description: "Skipping test 3")
    var flagGroupThree: ThreeFlags

    @Flag("Third level test flag")
    var thirdLevelFlag = false

    @Flag("Second Third level test flag")
    var thirdLevelFlag2 = false

}

@FlagContainer
private struct ThreeFlags {

    @Flag(keyStrategy: .customKey("customKey"), description: "Test flag with custom key")
    var custom = false

    @Flag(keyStrategy: .customKeyPath("customKeyPath"), description: "Test flag with custom key path")
    var full = false

    @Flag("Standard Flag")
    var standard = true

}
