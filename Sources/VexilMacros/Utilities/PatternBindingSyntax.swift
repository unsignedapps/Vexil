//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftSyntax

extension PatternBindingSyntax {

    var inferredType: TypeSyntax? {
        if let actualType = typeAnnotation?.type {
            return actualType
        }

        if let initializer {
            let value = initializer.value.as(ForceUnwrapExprSyntax.self)?.expression ?? initializer.value
            if value.is(BooleanLiteralExprSyntax.self) {
                return "Bool"
            } else if value.is(IntegerLiteralExprSyntax.self) {
                return "Int"
            } else if value.is(StringLiteralExprSyntax.self) {
                return "String"
            } else if value.is(FloatLiteralExprSyntax.self) {
                return "Double"
            } else if value.is(RegexLiteralExprSyntax.self) {
                return "Regex"
            } else if let function = value.as(FunctionCallExprSyntax.self) {
                if let identifier = function.calledExpression.as(DeclReferenceExprSyntax.self) {
                    return TypeSyntax(IdentifierTypeSyntax(name: identifier.baseName))
                } else if let memberAccess = function.calledExpression.as(MemberAccessExprSyntax.self)?.asMemberTypeSyntax() {
                    return TypeSyntax(memberAccess.baseType)
                }
            } else if let memberAccess = value.as(MemberAccessExprSyntax.self)?.asMemberTypeSyntax() {
                return TypeSyntax(memberAccess.baseType)
            }
        }

        return nil
    }

}

private extension MemberAccessExprSyntax {

    func asMemberTypeSyntax() -> MemberTypeSyntax? {
        guard let base else {
            return nil
        }
        if let nestedType = base.as(MemberAccessExprSyntax.self)?.asMemberTypeSyntax() {
            return MemberTypeSyntax(baseType: nestedType, name: declName.baseName)

        } else if let simpleBase = base.as(DeclReferenceExprSyntax.self) {
            return MemberTypeSyntax(baseType: IdentifierTypeSyntax(name: simpleBase.baseName), name: declName.baseName)

        } else {
            return nil
        }
    }

}

