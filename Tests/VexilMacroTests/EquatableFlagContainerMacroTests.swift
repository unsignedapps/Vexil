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

final class EquatableFlagContainerMacroTests: XCTestCase {

    func testExpandsDefault() throws {
        assertMacroExpansion(
            """
            @EquatableFlagContainer
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

            extension TestFlags: Equatable {
            }
            """,
            macros: [
                "EquatableFlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsPublic() throws {
        assertMacroExpansion(
            """
            @EquatableFlagContainer
            public struct TestFlags {
            }
            """,
            expandedSource:
            """

            public struct TestFlags {

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
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                public var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [:]
                }
            }

            extension TestFlags: Equatable {
            }
            """,
            macros: [
                "EquatableFlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsButAlreadyConforming() throws {
        assertMacroExpansion(
            """
            @EquatableFlagContainer
            struct TestFlags: FlagContainer {
            }
            """,
            expandedSource: """

            struct TestFlags: FlagContainer {

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

            extension TestFlags: Equatable {
            }
            """,
            macros: [
                "EquatableFlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsVisitorAndEquatableImplementation() throws {
        assertMacroExpansion(
            """
            @EquatableFlagContainer
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
                "EquatableFlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsVisitorAndEquatablePublicImplementation() throws {
        assertMacroExpansion(
            """
            @EquatableFlagContainer
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
                "EquatableFlagContainer": FlagContainerMacro.self,
            ]
        )
    }
}
