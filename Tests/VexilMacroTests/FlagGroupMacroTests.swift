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

#if canImport(VexilMacros)

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import VexilMacros
import XCTest

final class FlagGroupMacroTests: XCTestCase {

    func testExpands() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup("Test Flag Group")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "Test Flag Group",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testExpandsPublic() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup("Test Flag Group")
                public var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                public var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                public var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "Test Flag Group",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }


    // MARK: - Flag Group Detail Tests

    func testExpandsName() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(name: "Test Group", keyStrategy: .default, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Group",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testHidden() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .default, description: "meow", display: .hidden)
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .hidden,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testDisplayNavigation() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .default, description: "meow", display: .navigation)
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testDisplaySection() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .default, description: "meow", display: .section)
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .section,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    // MARK: - Key Strategy Detection Tests

    func testDetectsKeyStrategyMinimal() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .default, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testDetectsKeyStrategyFull() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: VexilConfiguration.GroupKeyStrategy.default, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }


    // MARK: - Key Strategy Tests

    func testKeyStrategyDefault() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .default, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.automatic("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testKeyStrategyKebabcase() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .kebabcase, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.kebabcase("test-subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.kebabcase("test-subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testKeyStrategySnakecase() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .snakecase, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.snakecase("test_subgroup")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.snakecase("test_subgroup")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testKeyStrategySkip() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .skip, description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath, _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath,
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

    func testKeyStrategyCustomKey() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(keyStrategy: .customKey("test"), description: "meow")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append(.customKey("test")), _flagLookup: _flagLookup)
                    }
                }

                var $testSubgroup: FlagGroupWigwag<SubgroupFlags> {
                    FlagGroupWigwag(
                        keyPath: _flagKeyPath.append(.customKey("test")),
                        name: "Test Subgroup",
                        description: "meow",
                        displayOption: .navigation,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

}

#endif // canImport(VexilMacros)
