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

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import VexilMacros
import XCTest

final class EquatableFlagContainerMacroTests: XCTestCase {

    func testDoesntGenerateWhenEmpty() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            struct TestFlags {
            }
            """,
            expandedSource: """

            struct TestFlags {

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [:]
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsInternal() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            struct TestFlags {
                @Flag(default: false, description: "Some Flag")
                var someFlag: Bool
            }
            """,
            expandedSource: """

            struct TestFlags {
                var someFlag: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag"))) ?? false
                    }
                }

                var $someFlag: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        name: nil,
                        defaultValue: false,
                        description: "Some Flag",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $someFlag
                        }
                    )
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.someFlag: _flagKeyPath.append(.automatic("some-flag")),
                        ]
                }
            }

            extension TestFlags: Equatable {
                static func == (lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.someFlag == rhs.someFlag
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsPublic() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            public struct TestFlags {
                @Flag(default: false, description: "Some Flag")
                var someFlag: Bool
            }
            """,
            expandedSource:
            """

            public struct TestFlags {
                var someFlag: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag"))) ?? false
                    }
                }

                var $someFlag: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        name: nil,
                        defaultValue: false,
                        description: "Some Flag",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                public init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                public func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $someFlag
                        }
                    )
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                public var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.someFlag: _flagKeyPath.append(.automatic("some-flag")),
                        ]
                }
            }

            extension TestFlags: Equatable {
                public static func == (lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.someFlag == rhs.someFlag
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsButAlreadyConforming() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            struct TestFlags: FlagContainer {
                @Flag(default: false, description: "Some Flag")
                var someFlag: Bool
            }
            """,
            expandedSource: """

            struct TestFlags: FlagContainer {
                var someFlag: Bool {
                    get {
                        _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag"))) ?? false
                    }
                }

                var $someFlag: FlagWigwag<Bool> {
                    FlagWigwag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        name: nil,
                        defaultValue: false,
                        description: "Some Flag",
                        displayOption: .default,
                        lookup: _flagLookup
                    )
                }

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("some-flag")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("some-flag")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $someFlag
                        }
                    )
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.someFlag: _flagKeyPath.append(.automatic("some-flag")),
                        ]
                }
            }

            extension TestFlags: Equatable {
                static func == (lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.someFlag == rhs.someFlag
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
                "Flag": FlagMacro.self,
            ]
        )
    }

    func testExpandsVisitorAndEquatableImplementation() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            struct TestFlags {
                @Flag(default: false, description: "Flag 1")
                var first: Bool
                @FlagGroup(description: "Test Group")
                var flagGroup: GroupOfFlags
                @Flag(default: false, description: "Flag 2")
                var second: Bool
            }
            """,
            expandedSource: """

            struct TestFlags {
                @Flag(default: false, description: "Flag 1")
                var first: Bool
                @FlagGroup(description: "Test Group")
                var flagGroup: GroupOfFlags
                @Flag(default: false, description: "Flag 2")
                var second: Bool

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("first")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("first")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $first
                        }
                    )
                    flagGroup.walk(visitor: visitor)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("second")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("second")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $second
                        }
                    )
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.first: _flagKeyPath.append(.automatic("first")),
                        \\TestFlags.second: _flagKeyPath.append(.automatic("second")),
                        ]
                }
            }

            extension TestFlags: Equatable {
                static func == (lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.first == rhs.first &&
                    lhs.flagGroup == rhs.flagGroup &&
                    lhs.second == rhs.second
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsVisitorAndEquatablePublicImplementation() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            public struct TestFlags {
                @Flag(default: false, description: "Flag 1")
                public var first: Bool
                @FlagGroup(description: "Test Group")
                public var flagGroup: GroupOfFlags
                @Flag(default: false, description: "Flag 2")
                public var second: Bool
            }
            """,
            expandedSource: """

            public struct TestFlags {
                @Flag(default: false, description: "Flag 1")
                public var first: Bool
                @FlagGroup(description: "Test Group")
                public var flagGroup: GroupOfFlags
                @Flag(default: false, description: "Flag 2")
                public var second: Bool

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                public init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                public func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("first")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("first")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $first
                        }
                    )
                    flagGroup.walk(visitor: visitor)
                    visitor.visitFlag(
                        keyPath: _flagKeyPath.append(.automatic("second")),
                        value: { [self] in
                            _flagLookup.value(for: _flagKeyPath.append(.automatic("second")))
                        },
                        defaultValue: false,
                        wigwag: { [self] in
                            $second
                        }
                    )
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                public var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.first: _flagKeyPath.append(.automatic("first")),
                        \\TestFlags.second: _flagKeyPath.append(.automatic("second")),
                        ]
                }
            }

            extension TestFlags: Equatable {
                public static func == (lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.first == rhs.first &&
                    lhs.flagGroup == rhs.flagGroup &&
                    lhs.second == rhs.second
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }
}
