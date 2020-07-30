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

    /// The flag's key
    let key: String

    /// The name of the unfurled flag or flag group
    let name: String

    /// A brief description of the unfurled flag or flag group
    let description: String


    // MARK: - Initialisation

    init (key: String, info: FlagInfo, defaultName: String) {
        self.key = key
        self.name = info.name ?? defaultName
        self.description = info.description
    }
}

#endif
