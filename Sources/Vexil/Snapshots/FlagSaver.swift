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
    let flags: Set<String>
    var error: Error?

    init(source: any FlagValueSource, flags: Set<String>) {
        self.source = source
        self.flags = flags
    }

    func visitFlag<Value>(keyPath: FlagKeyPath, value: Value, sourceName: String?) where Value: FlagValue {
        let key = keyPath.key
        guard error == nil, flags.contains(key) else {
            return
        }
        do {
            try source.setFlagValue(value, key: key)
        } catch {
            self.error = error
        }
    }

}
