//
//  FlagValueControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

import SwiftUI
import Vexil

protocol FlagValueControl {
    associatedtype BindingValue: FlagValue
    func control<RootGroup> (label: String, flag: UnfurledFlag<BindingValue, RootGroup>, manager: FlagValueManager<RootGroup>) -> AnyView where RootGroup: FlagContainer
}

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

