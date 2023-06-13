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

final class FlagMacroTests: XCTestCase {

    // MARK: - Type Tests

    func testExpandsBool() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsDouble() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(default: 123.456, description: "meow")
                var testProperty: Double
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Double {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? 123.456
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsString() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(default: "alpha", description: "meow")
                var testProperty: String
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: String {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? "alpha"
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsEnum() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(default: .testCase, description: "meow")
                var testProperty: SomeEnum
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: SomeEnum {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? .testCase
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }


    // MARK: - Argument Tests

    func testExpandsName() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(name: "Super Test!", default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }


    // MARK: - Key Strategy Detection Tests

    func testDetectsKeyStrategyMinimal() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .default, default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testDetectsKeyStrategyFull() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: VexilConfiguration.FlagKeyStrategy.default, default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }


    // MARK: - Key Strategy Tests

    func testKeyStrategyDefault() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .default, default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testKeyStrategyKebabcase() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .kebabcase, default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test-property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testKeyStrategySnakecase() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .snakecase, default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test_property")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testKeyStrategyCustomKey() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .customKey("test"), default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append("test")) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testKeyStrategyCustomKeyPath() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(keyStrategy: .customKeyPath("test"), default: false, description: "meow")
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: FlagKeyPath("test", separator: _flagKeyPath.separator)) ?? false
                    }
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

}