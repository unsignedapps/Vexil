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

import Foundation
import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlag<Value, RootGroup>: UnfurledFlagItem, Identifiable where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let info: UnfurledFlagInfo
    let flag: Flag<Value>
    let hasChildren = false

    private let manager: FlagValueManager<RootGroup>

    var id: UUID {
        flag.id
    }

    var isEditable: Bool {
        self is BooleanEditableFlag
            || self is CaseIterableEditableFlag
            || self is StringEditableFlag
            || self is OptionalBooleanEditableFlag
            || self is OptionalCaseIterableEditableFlag
            || self is OptionalStringEditableFlag
    }

    var childLinks: [UnfurledFlagItem]? {
        nil
    }

    var isLink: Bool {
        false
    }

    // MARK: - Initialisation

    init(name: String, flag: Flag<Value>, manager: FlagValueManager<RootGroup>) {
        self.info = UnfurledFlagInfo(key: flag.key, info: flag.info, defaultName: name)
        self.flag = flag
        self.manager = manager
    }


    // MARK: - Unfurled Flag Item Conformance

    var unfurledView: AnyView {
        AnyView(UnfurledFlagView(flag: self, manager: manager))
    }

}

#endif
