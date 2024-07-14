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

public struct FlagMacro {

    // MARK: - Properties

    let propertyName: String
    let key: ExprSyntax
    let name: ExprSyntax?
    let defaultValue: ExprSyntax
    let description: ExprSyntax
    let display: ExprSyntax?
    let type: TypeSyntax


    // MARK: - Initialisation

    /// Create a FlagMacro from the given attribute/declaration
    init(node: AttributeSyntax, declaration: some DeclSyntaxProtocol, context: some MacroExpansionContext) throws {
        guard node.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Flag" else {
            throw Diagnostic.notFlagMacro
        }
        guard let arguments = node.arguments else {
            throw Diagnostic.missingArguments
        }

        // Description can have an explicit or omitted label
        guard let description = arguments.descriptionArgument  else {
            throw Diagnostic.missingDescription
        }

        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type ?? binding.inferredType,
            binding.accessorBlock == nil
        else {
            throw Diagnostic.onlySimpleVariableSupported
        }

        guard let defaultExprSyntax = arguments[label: "default"]?.expression ?? binding.initializer?.value else {
            throw Diagnostic.missingDefaultValue
        }

        let strategy = KeyStrategy(exprSyntax: arguments[label: "keyStrategy"]?.expression) ?? .default

        if let nameExprSyntax = arguments[label: "name"] {
            self.name = nameExprSyntax.expression
        } else {
            self.name = nil
        }

        self.propertyName = identifier.text
        self.key = strategy.createKey(identifier.text)
        self.defaultValue = defaultExprSyntax.trimmed
        self.type = type.trimmed
        self.description = description.expression.trimmed
        self.display = arguments[label: "display"]?.expression.trimmed
    }


    // MARK: - Expression Creation

    func makeLookupExpression() -> CodeBlockItemSyntax {
        """
        _flagLookup.value(for: \(key)) ?? \(defaultValue)
        """
    }

    func makeVisitExpression() -> CodeBlockItemSyntax {
        """
        visitor.visitFlag(
            keyPath: \(key),
            value: { [self] in _flagLookup.value(for: \(key)) },
            defaultValue: \(defaultValue),
            wigwag: { [self] in $\(raw: propertyName) }
        )
        """
    }

}

private extension AttributeSyntax.Arguments {

    var descriptionArgument: LabeledExprSyntax? {
        if let argument = self[label: "description"] {
            return argument
        }

        // Support for the single description property overload, ie @Flag("description")
        if case let .argumentList(list) = self, list.count == 1, let argument = list.first, argument.label == nil {
            return argument
        }

        // Not found
        return nil
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


// MARK: - Peer Macro Creation

extension FlagMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            let macro = try FlagMacro(node: node, declaration: declaration, context: context)
            return [
                """
                var $\(raw: macro.propertyName): FlagWigwag<\(macro.type)> {
                    FlagWigwag(
                        keyPath: \(macro.key),
                        name: \(macro.name ?? "nil"),
                        defaultValue: \(macro.defaultValue),
                        description: \(macro.description),
                        displayOption: \(macro.display ?? ".default"),
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

extension FlagMacro {

    enum Diagnostic: Error {
        case notFlagMacro
        case missingArguments
        case missingDefaultValue
        case missingDescription
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
                switch memberAccess.declName.baseName.text {
                case "default":             self = .default
                case "kebabcase":           self = .kebabcase
                case "snakecase":           self = .snakecase
                default:                    return nil
                }

            } else if
                let functionCall = exprSyntax?.as(FunctionCallExprSyntax.self),
                let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
                let stringLiteral = functionCall.arguments.first?.expression.as(StringLiteralExprSyntax.self),
                let string = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
            {
                switch memberAccess.declName.baseName.text {
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
            case .default:
                "_flagKeyPath.append(.automatic(\(StringLiteralExprSyntax(content: propertyName.convertedToSnakeCase(separator: "-")))))"

            case .kebabcase:
                "_flagKeyPath.append(.kebabcase(\(StringLiteralExprSyntax(content: propertyName.convertedToSnakeCase(separator: "-")))))"

            case .snakecase:
                "_flagKeyPath.append(.snakecase(\(StringLiteralExprSyntax(content: propertyName.convertedToSnakeCase()))))"

            case let .customKey(key):
                "_flagKeyPath.append(.customKey(\(StringLiteralExprSyntax(content: key))))"

            case let .customKeyPath(keyPath):
                "FlagKeyPath(\(StringLiteralExprSyntax(content: keyPath)), separator: _flagKeyPath.separator, strategy: _flagKeyPath.strategy)"
            }
        }

    }

}
