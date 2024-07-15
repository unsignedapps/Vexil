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

#if canImport(VexilMacros)

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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? 123.456
                    }
                }

                var $testProperty: FlagWigwag<Double> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: 123.456,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? "alpha"
                    }
                }

                var $testProperty: FlagWigwag<String> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: "alpha",
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? .testCase
                    }
                }

                var $testProperty: FlagWigwag<SomeEnum> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: .testCase,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }


    // MARK: - Property Initialisation Tests

    func testExpandsBoolPropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = false
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsDoublePropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = 123.456
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? 123.456
                    }
                }

                var $testProperty: FlagWigwag<Double> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: 123.456,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsStringPropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = "alpha"
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? "alpha"
                    }
                }

                var $testProperty: FlagWigwag<String> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: "alpha",
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsEnumPropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = SomeEnum.testCase
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? SomeEnum.testCase
                    }
                }

                var $testProperty: FlagWigwag<SomeEnum> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: SomeEnum.testCase,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Super Test!",
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testHiddenDescription() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(name: "Super Test!", default: false, description: "Test", display: .hidden)
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Super Test!",
                        defaultValue: false,
                        description: "Test",
                        displayOption: .hidden,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testHiddenDescriptionExplicit() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag(name: "Super Test!", default: false, description: "Test", display: FlagDisplayOption.hidden)
                var testProperty: Bool
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Super Test!",
                        defaultValue: false,
                        description: "Test",
                        displayOption: FlagDisplayOption.hidden,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.kebabcase("test-property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.kebabcase("test-property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.snakecase("test_property"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.snakecase("test_property")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: _flagKeyPath.append(.customKey("test"))) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.customKey("test")),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
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
                        _flagLookup.value(for: FlagKeyPath("test", separator: _flagKeyPath.separator, strategy: _flagKeyPath.strategy)) ?? false
                    }
                }

                var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: FlagKeyPath("test", separator: _flagKeyPath.separator, strategy: _flagKeyPath.strategy),
                        name: nil,
                        defaultValue: false,
                        description: "meow",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }
            }
            """,
            macros: [
                "Flag": FlagMacro.self,
            ]
        )
    }

}

#endif // canImport(VexilMacros)
