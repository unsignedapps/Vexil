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

final class FlagContainerMacroTests: XCTestCase {

    func testExpandsDefault() throws {
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
                    visitor.beginContainer(keyPath: _flagKeyPath, containerType: TestFlags.self)
                    visitor.endContainer(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [:]
                }
            }

            extension TestFlags: Equatable {
                static func ==(lhs: TestFlags, rhs: TestFlags) -> Bool {
                    true
                }
            }

            extension TestFlags: Sendable {
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsPublic() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            public struct TestFlags {
            }
            """,
            expandedSource: """

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
                    visitor.beginContainer(keyPath: _flagKeyPath, containerType: TestFlags.self)
                    visitor.endContainer(keyPath: _flagKeyPath)
                }
                public var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [:]
                }
            }

            extension TestFlags: Equatable {
                public static func ==(lhs: TestFlags, rhs: TestFlags) -> Bool {
                    true
                }
            }

            extension TestFlags: Sendable {
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsButAlreadyConforming() throws {
        assertMacroExpansion(
            """
            @FlagContainer
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
                    visitor.beginContainer(keyPath: _flagKeyPath, containerType: TestFlags.self)
                    visitor.endContainer(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [:]
                }
            }

            extension TestFlags: Equatable {
                static func ==(lhs: TestFlags, rhs: TestFlags) -> Bool {
                    true
                }
            }

            extension TestFlags: Sendable {
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    // MARK: - Swift 6 specific tests

    func testExpandsVisitorImplementation() throws {
        assertMacroExpansion(
            """
            @FlagContainer
            struct TestFlags {
                @Flag("Flag 1")
                var first = false
                @FlagGroup("Test Group")
                var flagGroup: GroupOfFlags
                @Flag("Flag 2")
                var second = false
            }
            """,
            expandedSource: """

            struct TestFlags {
                @Flag("Flag 1")
                var first = false
                @FlagGroup("Test Group")
                var flagGroup: GroupOfFlags
                @Flag("Flag 2")
                var second = false

                fileprivate let _flagKeyPath: FlagKeyPath

                fileprivate let _flagLookup: any FlagLookup

                init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
            }

            extension TestFlags: FlagContainer {
                func walk(visitor: any FlagVisitor) {
                    visitor.beginContainer(keyPath: _flagKeyPath, containerType: TestFlags.self)
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
                    visitor.beginGroup(
                        keyPath: _flagKeyPath.append(.automatic("flag-group")),
                        wigwag: {
                            FlagGroupWigwag<GroupOfFlags>(
                                keyPath: _flagKeyPath.append(.automatic("flag-group")),
                                name: "Flag Group",
                                description: "Test Group",
                                displayOption: .navigation,
                                lookup: _flagLookup
                            )
                        }
                    )
                    flagGroup.walk(visitor: visitor)
                    visitor.endGroup(keyPath: _flagKeyPath.append(.automatic("flag-group")))
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
                    visitor.endContainer(keyPath: _flagKeyPath)
                }
                var _allFlagKeyPaths: [PartialKeyPath<TestFlags>: FlagKeyPath] {
                    [
                        \\TestFlags.first: _flagKeyPath.append(.automatic("first")),
                        \\TestFlags.second: _flagKeyPath.append(.automatic("second")),
                    ]
                }
            }

            extension TestFlags: Equatable {
                static func ==(lhs: TestFlags, rhs: TestFlags) -> Bool {
                    lhs.first == rhs.first &&
                    lhs.flagGroup == rhs.flagGroup &&
                    lhs.second == rhs.second
                }
            }

            extension TestFlags: Sendable {
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

}

#endif // canImport(VexilMacros)
