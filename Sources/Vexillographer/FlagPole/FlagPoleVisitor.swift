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

import SwiftUI
import Vexil

class FlagPoleVisitor: FlagVisitor {

    var lookup: any FlagLookup
    var items = [any FlagPoleItem]()
    var groupStack = [any FlagPoleItemGroup]()
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()

    init(lookup: any FlagLookup) {
        self.lookup = lookup
    }

    func beginContainer(keyPath: FlagKeyPath, containerType: any FlagContainer.Type) {
        let container = containerType.init(_flagKeyPath: keyPath, _flagLookup: lookup)
        keyPathByFlagKeyPath.merge(container.keyPathByFlagKeyPath, uniquingKeysWith: { $1 })
    }

    func beginGroup(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<some FlagContainer>) {
        groupStack.append(FlagGroupItem(wigwag()))
    }

    func visitFlag<Value: FlagValue>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) {
        appendToGroupOrRoot(FlagItem(wigwag()))
    }

    func endGroup(keyPath: FlagKeyPath) {
        appendToGroupOrRoot(groupStack.removeLast())
    }

    private func appendToGroupOrRoot(_ newItem: any FlagPoleItem) {
        if groupStack.last != nil {
            groupStack[groupStack.count - 1].items.append(newItem)
        } else {
            items.append(newItem)
        }
    }

}

private extension FlagContainer {

    /// A map of type-erased key paths by flag key path.
    var keyPathByFlagKeyPath: [FlagKeyPath: AnyKeyPath] {
        Dictionary(uniqueKeysWithValues: _allFlagKeyPaths.map { ($0.value, $0.key) })
    }

}
