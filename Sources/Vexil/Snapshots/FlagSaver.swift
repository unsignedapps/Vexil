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

class FlagSaver: FlagVisitor {

    let source: any FlagValueSource
    let flags: Set<FlagKeyPath>
    var error: Error?

    init(source: any FlagValueSource, flags: Set<FlagKeyPath>) {
        self.source = source
        self.flags = flags
    }

    func visitFlag<Value>(keyPath: FlagKeyPath, value: Value, sourceName: String?) where Value: FlagValue {
        guard error == nil, flags.contains(keyPath) else {
            return
        }
        do {
            try source.setFlagValue(value, key: keyPath.key)
        } catch {
            self.error = error
        }
    }

}
