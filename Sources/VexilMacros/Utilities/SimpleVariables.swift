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
import SwiftSyntaxMacros

extension MemberBlockSyntax {

    var variables: [VariableDeclSyntax] {
        members.compactMap { member in
            member.decl.as(VariableDeclSyntax.self)
        }
    }

}

extension VariableDeclSyntax {

    func asFlag(in context: some MacroExpansionContext) -> FlagMacro? {
        guard let attribute = attributes.first?.as(AttributeSyntax.self) else {
            return nil
        }
        return try? FlagMacro(node: attribute, declaration: self, context: context)
    }

    func asFlagGroup(in context: some MacroExpansionContext) -> FlagGroupMacro? {
        guard let attribute = attributes.first?.as(AttributeSyntax.self) else {
            return nil
        }
        return try? FlagGroupMacro(node: attribute, declaration: self, context: context)
    }

}
