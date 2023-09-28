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

import Foundation
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
        [

            // Properties

            """
            fileprivate let _flagKeyPath: FlagKeyPath
            """,
            """
            fileprivate let _flagLookup: any FlagLookup
            """,

            // Initialisation

            try DeclSyntax(
                InitializerDeclSyntax("init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup)") {
                    ExprSyntax("self._flagKeyPath = _flagKeyPath")
                    ExprSyntax("self._flagLookup = _flagLookup")
                }
                    .with(\.modifiers, declaration.modifiers.scopeSyntax)
            ),

        ]
    }

}

extension FlagContainerMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Check that conformance doesn't already exist, or that we are inside a unit test.
        // The latter is a workaround for https://github.com/apple/swift-syntax/issues/2031
        guard protocols.isEmpty == false || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil else {
            return []
        }

        return [
            try ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: .init(inheritedTypes: [ .init(type: TypeSyntax(stringLiteral: "FlagContainer")) ])
            ) {

                // Flag Hierarchy Walking

                try DeclSyntax(FunctionDeclSyntax("func walk(visitor: any FlagVisitor)") {
                    "visitor.beginGroup(keyPath: _flagKeyPath)"
                    for variable in declaration.memberBlock.variables {
                        if let flag = variable.asFlag(in: context) {
                            flag.makeVisitExpression()
                        } else if let group = variable.asFlagGroup(in: context) {
                            group.makeVisitExpression()
                        }
                    }
                    "visitor.endGroup(keyPath: _flagKeyPath)"
                })

                // Flag Key Paths

                try DeclSyntax(VariableDeclSyntax("var _allFlagKeyPaths: [PartialKeyPath<\(type)>: FlagKeyPath]") {
                    let variables = declaration.memberBlock.variables
                    if variables.isEmpty == false {
                        DictionaryExprSyntax(leftSquare: .leftSquareToken(trailingTrivia: .newline)) {
                            for variable in variables {
                                if let flag = variable.asFlag(in: context) {
                                    DictionaryElementSyntax(
                                        leadingTrivia: .spaces(4),
                                        key: KeyPathExprSyntax(
                                            root: type,
                                            components: [
                                                .init(
                                                    period: .periodToken(),
                                                    component: .property(.init(declName: .init(baseName: .identifier(flag.propertyName))))
                                                )
                                            ]
                                        ),
                                        value: flag.key,
                                        trailingComma: .commaToken(),
                                        trailingTrivia: .newline
                                    )
                                }
                            }
                        }

                    } else {
                        "[:]"
                    }
                })

            }
                .with(\.modifiers, declaration.modifiers.scopeSyntax)
        ]
    }

}

// MARK: - Scopes

private extension DeclModifierListSyntax {
    var scopeSyntax: DeclModifierListSyntax {
        filter { modifier in
            if case let .keyword(keyword) = modifier.name.tokenKind, keyword == .public {
                return true
            } else {
                return false
            }
        }
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
