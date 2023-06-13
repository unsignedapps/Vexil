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

public struct FlagMacro {

    // MARK: - Properties

    let propertyName: String
    let key: ExprSyntax
    let defaultValue: ExprSyntax
    let type: TypeSyntax


    // MARK: - Initialisation

    /// Create a FlagMacro from the given attribute/declaration
    init(node: AttributeSyntax, declaration: some DeclSyntaxProtocol, context: some MacroExpansionContext) throws {
        guard node.attributeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "Flag" else {
            throw Diagnostic.notFlagMacro
        }
        guard let argument = node.argument else {
            throw Diagnostic.missingArgument
        }
        guard let defaultExprSyntax = argument[label: "default"] else {
            throw Diagnostic.missingDefaultValue
        }

        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type,
            binding.accessor == nil
        else {
            throw Diagnostic.onlySimpleVariableSupported
        }

        let strategy = KeyStrategy(exprSyntax: argument[label: "keyStrategy"]?.expression) ?? .default

        self.propertyName = identifier.text
        self.key = strategy.createKey(identifier.text)
        self.defaultValue = defaultExprSyntax.expression
        self.type = type
    }


    // MARK: - Expression Creation

    func makeLookupExpression() -> CodeBlockItemSyntax {
        """
        _flagLookup.value(for: \(key)) ?? \(defaultValue)
        """
    }

    func makeVisitExpression() -> CodeBlockItemSyntax {
        """
        do {
            let keyPath = \(key)
            let located = _flagLookup.locate(keyPath: keyPath, of: \(type).self)
            visitor.visitFlag(keyPath: keyPath, value: located?.value ?? \(defaultValue), sourceName: located?.sourceName)
        }
        """
    }

}


// MARK: - Accessor Macro Creation

extension FlagMacro: AccessorMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        do {
            let macro = try FlagMacro(node: node, declaration: declaration, context: context)
            return [
                """
                get {
                    \(macro.makeLookupExpression())
                }
                """,
            ]
        } catch {
            return []
        }
    }

}

// MARK: - Diagnostics

extension FlagMacro {

    enum Diagnostic: Error {
        case notFlagMacro
        case missingArgument
        case missingDefaultValue
        case onlySimpleVariableSupported
    }

}

// MARK: - Coding Key Strategy

extension FlagMacro {

    /// This is a mirror of `VexilConfiguration.FlagKeyStrategy` so that we can work with it ourselves
    enum KeyStrategy {
        case `default`
        case kebabcase
        case snakecase
        case customKey(String)
        case customKeyPath(String)

        init?(exprSyntax: ExprSyntax?) {
            if let memberAccess = exprSyntax?.as(MemberAccessExprSyntax.self) {
                switch memberAccess.name.text {
                case "default":             self = .default
                case "kebabcase":           self = .kebabcase
                case "snakecase":           self = .snakecase
                default:                    return nil
                }

            } else if
                let functionCall = exprSyntax?.as(FunctionCallExprSyntax.self),
                let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
                let stringLiteral = functionCall.argumentList.first?.expression.as(StringLiteralExprSyntax.self),
                let string = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
            {
                switch memberAccess.name.text {
                case "customKey":           self = .customKey(string.content.text)
                case "customKeyPath":       self = .customKeyPath(string.content.text)
                default:                    return nil
                }

            } else {
                return nil
            }
        }

        func createKey(_ propertyName: String) -> ExprSyntax {
            switch self {
            case .default, .kebabcase:
                return "_flagKeyPath.append(\(StringLiteralExprSyntax(content: propertyName.convertedToSnakeCase(separator: "-"))))"

            case .snakecase:
                return "_flagKeyPath.append(\(StringLiteralExprSyntax(content: propertyName.convertedToSnakeCase())))"

            case let .customKey(key):
                return "_flagKeyPath.append(\(StringLiteralExprSyntax(content: key)))"

            case let .customKeyPath(keyPath):
                return "FlagKeyPath(\(StringLiteralExprSyntax(content: keyPath)), separator: _flagKeyPath.separator)"
            }
        }

    }

}
