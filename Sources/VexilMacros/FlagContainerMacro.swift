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
        // If the declaration doesn't have any scopes attached we might be inheriting scopes from a public extension
        var scopes = declaration.modifiers.scopeSyntax
        if scopes.isEmpty, let parent = context.lexicalContext.first?.as(ExtensionDeclSyntax.self) {
            scopes = parent.modifiers.scopeSyntax
        }

        return try [

            // Properties

            """
            fileprivate let _flagKeyPath: FlagKeyPath
            """,
            """
            fileprivate let _flagLookup: any FlagLookup
            """,

            // Initialisation

            DeclSyntax(
                InitializerDeclSyntax("init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup)") {
                    ExprSyntax("self._flagKeyPath = _flagKeyPath")
                    ExprSyntax("self._flagLookup = _flagLookup")
                }
                .with(\.modifiers, scopes)
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
        var shouldGenerateConformance = protocols.isEmpty && ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            ? node.shouldGenerateConformance
            : protocols.shouldGenerateConformance

        // Check if the user has disabled Equatable conformance manually
        if
            let equatableLiteral = node.arguments?[label: "generateEquatable"]?.expression.as(BooleanLiteralExprSyntax.self),
            case .keyword(.false) = equatableLiteral.literal.tokenKind
        {
            shouldGenerateConformance.equatable = false
        }

        // We also can't generate Equatable conformance if there is no variables to generate them
        if shouldGenerateConformance.equatable, declaration.memberBlock.variables.isEmpty {
            shouldGenerateConformance.equatable = false
        }

        // Check that conformance doesn't already exist, or that we are inside a unit test.
        // The latter is a workaround for https://github.com/apple/swift-syntax/issues/2031
        guard shouldGenerateConformance.flagContainer else {
            return []
        }

        // If the declaration doesn't have any scopes attached we might be inheriting scopes from a public extension
        var scopes = declaration.modifiers.scopeSyntax
        if scopes.isEmpty, let parent = context.lexicalContext.first?.as(ExtensionDeclSyntax.self) {
            scopes = parent.modifiers.scopeSyntax
        }

        var decls = try [
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: .init(inheritedTypes: [ .init(type: TypeSyntax(stringLiteral: "FlagContainer")) ])
            ) {

                // Flag Hierarchy Walking

                try FunctionDeclSyntax("func walk(visitor: any FlagVisitor)") {
                    "visitor.beginContainer(keyPath: _flagKeyPath, containerType: \(type).self)"
                    for variable in declaration.memberBlock.variables {
                        if let flag = variable.asFlag(in: context) {
                            flag.makeVisitExpression()
                        } else if let group = variable.asFlagGroup(in: context) {
                            group.makeVisitExpression()
                        }
                    }
                    "visitor.endContainer(keyPath: _flagKeyPath)"
                }
                .with(\.modifiers, scopes)

                // Flag Key Paths

                try VariableDeclSyntax("var _allFlagKeyPaths: [PartialKeyPath<\(type)>: FlagKeyPath]") {
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
                                                ),
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
                }
                .with(\.modifiers, scopes)

            },
        ]

        if shouldGenerateConformance.equatable {
            try decls += [
                ExtensionDeclSyntax(
                    extendedType: type,
                    inheritanceClause: .init(inheritedTypes: [ .init(type: TypeSyntax(stringLiteral: "Equatable")) ])
                ) {
                    var variables = declaration.memberBlock.storedVariables
                    if variables.isEmpty == false {
                        try FunctionDeclSyntax("func ==(lhs: \(type), rhs: \(type)) -> Bool") {
                            if let lastBinding = variables.removeLast().bindings.first?.pattern {
                                for variable in variables {
                                    if let binding = variable.bindings.first?.pattern {
                                        SequenceExprSyntax(elements: [
                                            ExprSyntax(PostfixOperatorExprSyntax(expression: ExprSyntax("lhs.\(binding)"), operator: .binaryOperator("=="))),
                                            ExprSyntax(PostfixOperatorExprSyntax(expression: ExprSyntax("rhs.\(binding)"), operator: .binaryOperator("&&"))),
                                        ])
                                    }
                                }
                                ExprSyntax("lhs.\(lastBinding) == rhs.\(lastBinding)")
                            }
                        }
                        .with(\.modifiers, Array(scopes) + [ DeclModifierSyntax(name: .keyword(.static)) ])
                    }
                },
            ]
        }

        return decls
    }

}

// MARK: - Scopes

extension DeclModifierListSyntax {
    var scopeSyntax: DeclModifierListSyntax {
        filter { modifier in
            if case let .keyword(keyword) = modifier.name.tokenKind, keyword == .public {
                true
            } else {
                false
            }
        }
    }
}

private extension TypeSyntax {
    var identifier: String? {
        for token in tokens(viewMode: .all) {
            if case let .identifier(identifier) = token.tokenKind {
                return identifier
            }
        }
        return nil
    }
}


// MARK: - Helpers

private extension [TypeSyntax] {

    var shouldGenerateConformance: (flagContainer: Bool, equatable: Bool) {
        reduce(into: (false, false)) { result, type in
            if type.identifier == "FlagContainer" {
                result = (true, result.1)
            } else if type.identifier == "Equatable" {
                result = (result.0, true)

                // For some reason Swift 5.9 concatenates these into a single `IdentifierTypeSyntax`
                // instead of providing them as array items
            } else if type.identifier == "FlagContainerEquatable" {
                result = (true, true)
            }
        }
    }

}

private extension AttributeSyntax {

    var shouldGenerateConformance: (flagContainer: Bool, equatable: Bool) {
        if attributeName.identifier == "FlagContainer" {
            (true, true)
        } else {
            (false, false)
        }
    }

}
