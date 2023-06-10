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
    
    public static func expansion<Node, Context>(of node: Node, in context: Context) throws -> ExprSyntax where Node: FreestandingMacroExpansionSyntax, Context: MacroExpansionContext {
        "print(\"moo\")"
    }

}
