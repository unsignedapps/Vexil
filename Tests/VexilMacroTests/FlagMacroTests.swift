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

final class FlagMacroTests: XCTestCase {

    // MARK: - Type Tests

    func testExpandsOptional() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty: Bool?
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty: Bool? {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? nil
                    }
                }

                var $testProperty: FlagWigwag<Bool?> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Test Property",
                        defaultValue: nil,
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

    func testExpandsPublic() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                public var testProperty: Bool = false
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                public var testProperty: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? false
                    }
                }

                public var $testProperty: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Test Property",
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
                        name: "Test Property",
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
                        name: "Test Property",
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
                        name: "Test Property",
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
                        name: "Test Property",
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

    func testExpandsTypePropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = SomeType(arg1: false)
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? SomeType(arg1: false)
                    }
                }

                var $testProperty: FlagWigwag<SomeType> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Test Property",
                        defaultValue: SomeType(arg1: false),
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

    func testExpandsForceUnwrapPropertyInitialization() throws {
        assertMacroExpansion(
            """
            struct TestFlags {
                @Flag("meow")
                var testProperty = URL(string: "https://test.com/")!
            }
            """,
            expandedSource:
            """
            struct TestFlags {
                var testProperty {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("test-property"))) ?? URL(string: "https://test.com/")!
                    }
                }

                var $testProperty: FlagWigwag<URL> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("test-property")),
                        name: "Test Property",
                        defaultValue: URL(string: "https://test.com/")!,
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
                @Flag(name: "Super Test!", description: "meow")
                var testProperty: Bool = false
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
                @Flag(name: "Super Test!", description: "Test", display: .hidden)
                var testProperty: Bool = false
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
                @Flag(name: "Super Test!", description: "Test", display: FlagDisplayOption.hidden)
                var testProperty: Bool = false
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
                @Flag(keyStrategy: .default, description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: VexilConfiguration.FlagKeyStrategy.default, description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: .default, description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: .kebabcase, description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: .snakecase, description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: .customKey("test"), description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
                @Flag(keyStrategy: .customKeyPath("test"), description: "meow")
                var testProperty: Bool = false
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
                        name: "Test Property",
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
