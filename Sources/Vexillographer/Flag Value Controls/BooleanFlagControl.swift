//
//  BooleanFlagControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

struct BooleanFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var showDetail: Bool
    @Binding var flagValue: Bool

    // MARK: - Views

    var body: some View {
        HStack {
            Toggle(self.label, isOn: self.$flagValue)
            DetailButton(showDetail: self.$showDetail)
        }
    }
}


// MARK: - Flag Control Creation

protocol BooleanEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> BooleanFlagControl where RootGroup: FlagContainer
}

extension UnfurledFlag: BooleanEditableFlag where Value == Bool {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> BooleanFlagControl where RootGroup: FlagContainer {
        let binding = Binding(key: self.flag.key, manager: manager, defaultValue: self.flag.defaultValue, transformer: PassthroughTransformer<Value>.self)
        return BooleanFlagControl (label: label, showDetail: showDetail, flagValue: binding)
    }
}

#endif
