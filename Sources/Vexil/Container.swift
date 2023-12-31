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

@attached(
    extension,
    conformances: FlagContainer, Equatable,
    names: named(_allFlagKeyPaths), named(walk(visitor:)), named(==)
)
@attached(
    member,
    names: named(_flagKeyPath), named(_flagLookup), named(init(_flagKeyPath:_flagLookup:))
)
public macro FlagContainer(
    generateEquatable: any ExpressibleByBooleanLiteral = true
) = #externalMacro(module: "VexilMacros", type: "FlagContainerMacro")

public protocol FlagContainer {
    init(_flagKeyPath: FlagKeyPath, _flagLookup: any FlagLookup)
    func walk(visitor: any FlagVisitor)
    var _allFlagKeyPaths: [PartialKeyPath<Self>: FlagKeyPath] { get }
}
