//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Vexil

struct Dependencies {
    var flags = FlagPole(
        hoist: FeatureFlags.self,
        sources: FlagPole<FeatureFlags>.defaultSources + [RemoteFlags.values]
    )

    @TaskLocal
    static var current = Dependencies()
}

enum RemoteFlags {
    static let values = FlagValueDictionary()
}
