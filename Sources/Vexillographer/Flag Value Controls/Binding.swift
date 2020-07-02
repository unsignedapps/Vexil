//
//  FlagValueControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if !os(Linux)

import SwiftUI
import Vexil

extension Binding {
    init<RootGroup> (flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.init (
            get: { flag.flag.wrappedValue },
            set: { newValue in
                do {
                    try manager.setFlagValue(newValue, key: flag.flag.key)

                } catch {
                    print("[Vexilographer] Could not set flag with key \"\(flag.flag.key)\" to \"\(newValue)\"")
                }
            }
        )
    }
}

#endif
