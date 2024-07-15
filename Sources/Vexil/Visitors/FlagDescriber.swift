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

final class FlagDescriber: FlagVisitor {

    var descriptions = [String]()

    func visitFlag<Value>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) where Value: FlagValue {
        let value = value()
        let description = (value as? CustomDebugStringConvertible)?.debugDescription
            ?? (value as? CustomStringConvertible)?.description
            ?? String(describing: value)
        descriptions.append("\(keyPath.key)=\(description)")
    }

}

