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
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self
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
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self
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
            }
            """,
            macros: [
                "FlagContainer": FlagContainerMacro.self
            ]
        )
    }

}
