//
//  UnfurledFlagInfo.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 15/7/20.
//

#if os(iOS) || os(macOS)

import Vexil

struct UnfurledFlagInfo {

    // MARK: - Properties

    /// The name of the unfurled flag or flag group
    let name: String

    /// A brief description of the unfurled flag or flag group
    let description: String


    // MARK: - Initialisation

    init (info: FlagInfo, defaultName: String) {
        self.name = info.name ?? defaultName
        self.description = info.description
    }
}

#endif
