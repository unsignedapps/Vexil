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

#if os(iOS) || os(macOS)

import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagInfo {

    // MARK: - Properties

    /// The flag's key
    let key: String

    /// The name of the unfurled flag or flag group
    let name: String

    /// A brief description of the unfurled flag or flag group
    let description: String


    // MARK: - Initialisation

    init(key: String, info: FlagInfo, defaultName: String) {
        self.key = key
        self.name = info.name ?? defaultName
        self.description = info.description
    }
}

#endif
