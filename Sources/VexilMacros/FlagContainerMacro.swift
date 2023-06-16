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

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum FlagContainerMacro {}

extension FlagContainerMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let typeIdentifier = declaration.asProtocol(IdentifiedDeclSyntax.self)?.identifier else {
            return []
        }

        // Find the scope modifier if we have one
        let scope = declaration.modifiers?.scope
        return [

            // Properties

            """
            private let _flagKeyPath: FlagKeyPath
            """,
            """
            private let _flagLookup: any FlagLookup
            """,

            // Initialisation

            """
            \(raw: scope ?? "") init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                self._flagKeyPath = _flagKeyPath
                self._flagLookup = _flagLookup
            }
            """,

            // Flag Hierarchy Walking

            try DeclSyntax(FunctionDeclSyntax("\(raw: scope ?? "") func walk(visitor: any FlagVisitor)") {
                "visitor.beginGroup(keyPath: _flagKeyPath)"
                for variable in declaration.memberBlock.variables {
                    if let flag = variable.asFlag(in: context) {
                        flag.makeVisitExpression()
                    } else if let group = variable.asFlagGroup(in: context) {
                        group.makeVisitExpression()
                    }
                }
                "visitor.endGroup(keyPath: _flagKeyPath)"
            }),

            // Flag Key Path Lookup

            try DeclSyntax(FunctionDeclSyntax("\(raw: scope ?? "") func flagKeyPath(for keyPath: AnyKeyPath) -> FlagKeyPath?") {
                let variables = declaration.memberBlock.variables
                if variables.isEmpty == false {
                    "switch keyPath {"
                    for variable in variables {
                        if let flag = variable.asFlag(in: context) {
                            CodeBlockItemSyntax(stringLiteral:
                                """
                                case \\\(typeIdentifier.text).\(flag.propertyName):
                                    return \(flag.key)
                                """
                            )
                        }
                    }
                    "default: return nil"
                    "}"

                } else {
                    "nil"
                }
            }),

        ]
    }

}

extension FlagContainerMacro: ConformanceMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        let inheritanceList: InheritedTypeListSyntax?
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            inheritanceList = classDecl.inheritanceClause?.inheritedTypeCollection
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            inheritanceList = structDecl.inheritanceClause?.inheritedTypeCollection
        } else {
            inheritanceList = nil
        }

        if let inheritanceList {
            for inheritance in inheritanceList {
                if inheritance.typeName.identifier == "FlagContainer" {
                    return []
                }
            }
        }

        return [
            ("FlagContainer", nil),
        ]
    }

}

// MARK: - Scopes

private extension ModifierListSyntax {
    var scope: String? {
        first { modifier in
            if case let .keyword(keyword) = modifier.name.tokenKind, keyword == .public {
                return true
            } else {
                return false
            }
        }?
            .name
            .text
    }
}

private extension TypeSyntax {
    var identifier: String? {
        for token in tokens(viewMode: .all) {
            switch token.tokenKind {
            case let .identifier(identifier):
                return identifier
            default:
                break
            }
        }
        return nil
    }
}
