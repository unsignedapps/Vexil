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
import SwiftSyntaxMacros

@main
struct VexilMacroPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        FlagContainerMacro.self,
        FlagGroupMacro.self,
        FlagMacro.self,
    ]

}
