//
//  BooleanFlagControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

import SwiftUI
import Vexil

struct BooleanFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var flagValue: Bool


    // MARK: - Views

    var body: some View {
        Toggle(self.label, isOn: self.$flagValue)
    }
}


// MARK: - Flag Value Control Support

extension UnfurledFlag: FlagValueControl where Value == Bool {
    typealias BindingValue = Bool
    func control<RootGroup>(label: String, flag: UnfurledFlag<Bool, RootGroup>, manager: FlagValueManager<RootGroup>) -> AnyView where RootGroup : FlagContainer {
        return AnyView(BooleanFlagControl(label: label, flagValue: Binding(flag: flag, manager: manager)))
    }
}
