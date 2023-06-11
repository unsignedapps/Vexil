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
        // Find the scope modifier if we have one
        let scope = declaration.modifiers?.scope
        
        return [
            """
            private let _flagKeyPath: FlagKeyPath
            """,
            """
            private let _flagLookup: any FlagLookup
            """,
            """
            \(raw: scope ?? "") init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup) {
                self._flagKeyPath = _flagKeyPath
                self._flagLookup = _flagLookup
            }
            """
            ,
        ]
    }
    
}

extension FlagContainerMacro: ConformanceMacro {

    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingConformancesOf declaration: Declaration,
        in context: Context
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] where Declaration: DeclGroupSyntax, Context: MacroExpansionContext {
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
            ("FlagContainer", nil)
        ]
    }

}

// MARK: - Scopes

private extension ModifierListSyntax {
    var scope: String? {
        first { modifier in
            if case .keyword(let keyword) = modifier.name.tokenKind, keyword == .public {
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
            case .identifier(let identifier):
                return identifier
            default:
                break
            }
        }
        return nil
    }
}
