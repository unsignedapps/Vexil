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

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FlagGroupMacro {

    // MARK: - Properties

    let propertyName: String
    let key: ExprSyntax
    let name: ExprSyntax?
    let description: ExprSyntax?
    let displayOption: ExprSyntax?
    let type: TypeSyntax


    // MARK: - Initialisation

    init(node: AttributeSyntax, declaration: some DeclSyntaxProtocol, context: some MacroExpansionContext) throws {
        guard node.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "FlagGroup" else {
            throw Diagnostic.notFlagGroupMacro
        }
        guard let arguments = node.arguments else {
            throw Diagnostic.missingArguments
        }

        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type,
            binding.accessorBlock == nil
        else {
            throw Diagnostic.onlySimpleVariableSupported
        }

        let strategy = KeyStrategy(exprSyntax: arguments[label: "keyStrategy"]?.expression) ?? .default

        self.propertyName = identifier.text
        self.key = strategy.createKey(propertyName)
        self.type = type

        self.name = arguments[label: "name"]?.expression
        self.description = arguments[label: "description"]?.expression
        self.displayOption = arguments[label: "display"]?.expression
    }


    // MARK: - Expression Creation

    func makeAccessor() -> AccessorDeclSyntax {
        """
        get {
            \(type)(_flagKeyPath: \(key), _flagLookup: _flagLookup)
        }
        """
    }

    func makeVisitExpression() -> CodeBlockItemSyntax {
        """
        \(raw: propertyName).walk(visitor: visitor)
        """
    }

}

extension FlagGroupMacro: AccessorMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let group = try FlagGroupMacro(node: node, declaration: declaration, context: context)
        return [
            group.makeAccessor(),
        ]
    }

}


// MARK: - Peer Macro Creation

extension FlagGroupMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            let macro = try FlagGroupMacro(node: node, declaration: declaration, context: context)
            return [
                """
                var $\(raw: macro.propertyName): FlagGroupWigwag<\(macro.type)> {
                    FlagGroupWigwag(
                        keyPath: \(macro.key),
                        name: \(macro.name ?? "nil"),
                        description: \(macro.description ?? "nil"),
                        displayOption: \(macro.displayOption ?? ".navigation"),
                        lookup: _flagLookup
                    )
                }
                """,
            ]
        } catch {
            return []
        }
    }

}


// MARK: - Diagnostics

extension FlagGroupMacro {

    enum Diagnostic: Error {
        case notFlagGroupMacro
        case missingArguments
        case onlySimpleVariableSupported
    }

}

// MARK: - Coding Key Strategy

private extension FlagGroupMacro {

    /// This is a mirror of `VexilConfiguration.FlagKeyStrategy` so that we can work with it ourselves
    enum KeyStrategy {
        case `default`
        case kebabcase
        case snakecase
        case skip
        case customKey(String)

        init?(exprSyntax: ExprSyntax?) {
            if let memberAccess = exprSyntax?.as(MemberAccessExprSyntax.self) {
                switch memberAccess.declName.baseName.text {
                case "default":             self = .default
                case "kebabcase":           self = .kebabcase
                case "snakecase":           self = .snakecase
                case "skip":                self = .skip
                default:                    return nil
                }

            } else if
                let functionCall = exprSyntax?.as(FunctionCallExprSyntax.self),
                let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
                let stringLiteral = functionCall.arguments.first?.expression.as(StringLiteralExprSyntax.self),
                let string = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
            {
                if case "customKey" = memberAccess.declName.baseName.text {
                    self = .customKey(string.content.text)
                } else {
                    return nil
                }

            } else {
                return nil
            }
        }

        func createKey(_ propertyName: String) -> ExprSyntax {
            switch self {
            case .default:
                "_flagKeyPath.append(.automatic(\"\(raw: propertyName.convertedToSnakeCase(separator: "-"))\"))"
            case .kebabcase:
                "_flagKeyPath.append(.kebabcase(\"\(raw: propertyName.convertedToSnakeCase(separator: "-"))\"))"
            case .snakecase:
                "_flagKeyPath.append(.snakecase(\"\(raw: propertyName.convertedToSnakeCase())\"))"
            case .skip:
                "_flagKeyPath"
            case let .customKey(key):
                "_flagKeyPath.append(.customKey(\"\(raw: key)\"))"
            }
        }

    }

}
