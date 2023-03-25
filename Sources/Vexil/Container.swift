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

import Foundation

/// A `FlagContainer` is a type that encapsulates your `Flag` and `FlagGroup`
/// types. The only requirement of a `FlagContainer` is that it can be initialised
/// with an empty `init()`.
///
public protocol FlagContainer {
    init()
}
