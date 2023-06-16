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

// This macro also adds a conformance to `FlagContainer` but its impossible to test
// that with SwiftSyntax at the moment for some reason.

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
                private let _flagKeyPath: FlagKeyPath
                private let _flagLookup: any FlagLookup
                 init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
                 func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                 func flagKeyPath(for keyPath: AnyKeyPath) -> FlagKeyPath? {
                    nil
                }
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
                private let _flagKeyPath: FlagKeyPath
                private let _flagLookup: any FlagLookup
                public init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
                public func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                public func flagKeyPath(for keyPath: AnyKeyPath) -> FlagKeyPath? {
                    nil
                }
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
                private let _flagKeyPath: FlagKeyPath
                private let _flagLookup: any FlagLookup
                 init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                    self._flagKeyPath = _flagKeyPath
                    self._flagLookup = _flagLookup
                }
                 func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
                 func flagKeyPath(for keyPath: AnyKeyPath) -> FlagKeyPath? {
                    nil
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

    func testExpandsVisitorImplementation() throws {
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
                private let _flagKeyPath: FlagKeyPath
                private let _flagLookup: any FlagLookup
             init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                self._flagKeyPath = _flagKeyPath
                self._flagLookup = _flagLookup
                }
             func walk(visitor: any FlagVisitor) {
                    visitor.beginGroup(keyPath: _flagKeyPath)
                    do {
                        let keyPath = _flagKeyPath.append("first")
                        let located = _flagLookup.locate(keyPath: keyPath, of: Bool.self)
                        visitor.visitFlag(keyPath: keyPath, value: located?.value ?? false, sourceName: located?.sourceName)
                    }
                    flagGroup.walk(visitor: visitor)
                    do {
                        let keyPath = _flagKeyPath.append("second")
                        let located = _flagLookup.locate(keyPath: keyPath, of: Bool.self)
                        visitor.visitFlag(keyPath: keyPath, value: located?.value ?? false, sourceName: located?.sourceName)
                    }
                    visitor.endGroup(keyPath: _flagKeyPath)
                }
             func flagKeyPath(for keyPath: AnyKeyPath) -> FlagKeyPath? {
                    switch keyPath {
                    case \\TestFlags.first:
                        return _flagKeyPath.append("first")
                    case \\TestFlags.second:
                        return _flagKeyPath.append("second")
                    default:
                        return nil
                    }
                }
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self,
            ]
        )
    }

}
