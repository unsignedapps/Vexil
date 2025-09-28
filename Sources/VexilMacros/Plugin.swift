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
