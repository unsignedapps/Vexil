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

@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro FlagGroup(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.GroupKeyStrategy = .default,
    description: StaticString,
    display: VexilDisplayOption = .navigation
) = #externalMacro(module: "VexilMacros", type: "FlagGroupMacro")
