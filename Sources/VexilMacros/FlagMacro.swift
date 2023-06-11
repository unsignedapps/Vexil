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

public enum FlagMacro {}

extension FlagMacro: AccessorMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let argument = node.argument else {
            return []
        }
        guard let defaultExprSyntax = argument[label: "default"] else {
            return []
        }

        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            binding.accessor == nil
        else {
            return []
        }

        let strategy = KeyStrategy(exprSyntax: argument[label: "keyStrategy"]?.expression) ?? .default

        return [
            """
            get {
                _flagLookup.value(for: \(strategy.createKey(identifier.text))) ?? \(defaultExprSyntax.expression)
            }
            """,
        ]
    }

}

// MARK: - Coding Key Strategy

private extension FlagMacro {

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
                return "_flagKeyPath.append(\"\(raw: propertyName.convertedToSnakeCase(separator: "-"))\")"
            case .snakecase:
                return "_flagKeyPath.append(\"\(raw: propertyName.convertedToSnakeCase())\")"
            case let .customKey(key):
                return "_flagKeyPath.append(\"\(raw: key)\")"
            case let .customKeyPath(keyPath):
                return "FlagKeyPath(\"\(raw: keyPath)\", separator: _flagKeyPath.separator)"
            }
        }

    }

}
