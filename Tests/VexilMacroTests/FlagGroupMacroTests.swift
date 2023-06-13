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

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import VexilMacros
import XCTest

final class FlagGroupMacroTests: XCTestCase {

    func testExpands() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @FlagGroup(description: "Test Flag Group")
                var testSubgroup: SubgroupFlags
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testSubgroup: SubgroupFlags {
                    get {
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test-subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test-subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test-subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test-subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test-subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test_subgroup"), _flagLookup: _flagLookup)
                    }
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
                        SubgroupFlags(_flagKeyPath: _flagKeyPath.append("test"), _flagLookup: _flagLookup)
                    }
                }
            }
            """,
            macros: [
                "FlagGroup": FlagGroupMacro.self,
            ]
        )
    }

}