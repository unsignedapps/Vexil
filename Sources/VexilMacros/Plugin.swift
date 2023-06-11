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

//
//  Plugin.swift
//  Vexil: VexilMacros
//
//  Created by Rob Amos on 11/6/2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct VexilMacroPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        TestMacro.self,
    ]

}

public enum TestMacro: ExpressionMacro {

    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        "print(\"moo\")"
    }

}
