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

// swiftformat:disable redundantBackticks

import VexilMacros

@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag<Value: FlagValue>(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    default initialValue: Value,
    description: StaticString
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")

@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag<Value: FlagValue>(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    default initialValue: Value,
    display: FlagDisplayOption
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")
