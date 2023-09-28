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

final class KeyEncodingTests: XCTestCase {

    func testKebabCaseCodingKeyStrategy() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: nil, separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        XCTAssertEqual(pole.$topLevelFlag.key, "top-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.$secondLevelFlag.key, "one-flag-group.second-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key, "one-flag-group.two.third-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key, "one-flag-group.two.third-level-flag2")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key, "one-flag-group.two.customKey")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key, "customKeyPath")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key, "one-flag-group.two.standard")
    }

    func testSnakeCaseCodingKeyStrategy() {
        let config = VexilConfiguration(codingPathStrategy: .snakecase, prefix: nil, separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        XCTAssertEqual(pole.$topLevelFlag.key, "top_level_flag")
        XCTAssertEqual(pole.oneFlagGroup.$secondLevelFlag.key, "one_flag_group.second_level_flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key, "one_flag_group.two.third_level_flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key, "one_flag_group.two.third_level_flag2")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key, "one_flag_group.two.customKey")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key, "customKeyPath")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key, "one_flag_group.two.standard")
    }

    func testPrefixCodingKeyStrategy() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: "prefix", separator: ".")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        XCTAssertEqual(pole.$topLevelFlag.key, "prefix.top-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.$secondLevelFlag.key, "prefix.one-flag-group.second-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key, "prefix.one-flag-group.two.third-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key, "prefix.one-flag-group.two.third-level-flag2")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key, "prefix.one-flag-group.two.customKey")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key, "customKeyPath")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key, "prefix.one-flag-group.two.standard")
    }

    func testCustomSeparatorCodingKeyStrategy() {
        let config = VexilConfiguration(codingPathStrategy: .kebabcase, prefix: "prefix", separator: "/")
        let pole = FlagPole(hoist: TestFlags.self, configuration: config, sources: [])

        XCTAssertEqual(pole.$topLevelFlag.key, "prefix/top-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.$secondLevelFlag.key, "prefix/one-flag-group/second-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag.key, "prefix/one-flag-group/two/third-level-flag")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.$thirdLevelFlag2.key, "prefix/one-flag-group/two/third-level-flag2")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$custom.key, "prefix/one-flag-group/two/customKey")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$full.key, "customKeyPath")
        XCTAssertEqual(pole.oneFlagGroup.twoFlagGroup.flagGroupThree.$standard.key, "prefix/one-flag-group/two/standard")
    }
}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @FlagGroup(description: "Test 1")
    var oneFlagGroup: OneFlags

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

}

@FlagContainer
private struct OneFlags {

    @FlagGroup(keyStrategy: .customKey("two"), description: "Test Two")
    var twoFlagGroup: TwoFlags

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool
}

@FlagContainer
private struct TwoFlags {

    @FlagGroup(keyStrategy: .skip, description: "Skipping test 3")
    var flagGroupThree: ThreeFlags

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

    @Flag(default: false, description: "Second Third level test flag")
    var thirdLevelFlag2: Bool

}

@FlagContainer
private struct ThreeFlags {

    @Flag(keyStrategy: .customKey("customKey"), default: false, description: "Test flag with custom key")
    var custom: Bool

    @Flag(keyStrategy: .customKeyPath("customKeyPath"), default: false, description: "Test flag with custom key path")
    var full: Bool

    @Flag(default: true, description: "Standard Flag")
    var standard: Bool

}
