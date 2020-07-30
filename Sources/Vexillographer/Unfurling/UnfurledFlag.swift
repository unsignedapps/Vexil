//
//  UnfurledFlag.swift
//  Vexil
//
//  Created by Rob Amos on 16/6/20.
//

#if os(iOS) || os(macOS)

import Foundation
import SwiftUI
import Vexil

struct UnfurledFlag<Value, RootGroup>: UnfurledFlagItem, Identifiable where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let info: UnfurledFlagInfo
    let flag: Flag<Value>
    let hasChildren = false

    private let manager: FlagValueManager<RootGroup>

    var id: UUID {
        return self.flag.id
    }


    // MARK: - Initialisation

    init (name: String, flag: Flag<Value>, manager: FlagValueManager<RootGroup>) {
        self.info = UnfurledFlagInfo(key: flag.key, info: flag.info, defaultName: name)
        self.flag = flag
        self.manager = manager
    }


    // MARK: - Unfurled Flag Item Conformance

    var unfurledView: AnyView {
        return AnyView(UnfurledFlagView(flag: self, manager: self.manager))
    }

}

#endif
