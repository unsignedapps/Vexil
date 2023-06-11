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

@attached(member, names: named(_flagKeyPath), named(_flagLookup), named(init(_flagKeyPath:_flagLookup:)))
@attached(conformance)
public macro FlagContainer() = #externalMacro(module: "VexilMacros", type: "FlagContainerMacro")

public protocol FlagContainer {
    init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup)
}

