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

import VexilMacros

@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag<Value: FlagValue>(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    default initialValue: Value,
    description: FlagDescription
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")


// MARK: - Flag Description

/// A string description for a flag or flag group. This is used for type completion only, the @Flag macro
/// will handle transformation of the description to arguments on Wigwag.init()
public struct FlagDescription: ExpressibleByStringLiteral {

    private init() {
        // Intentionally left blank
    }

    public init(stringLiteral value: StaticString) {
        // Intentionally left blank
    }

    /// Hides the flag from flag editors like Vexillographer.
    public static var hidden: FlagDescription {
        FlagDescription()
    }

}
