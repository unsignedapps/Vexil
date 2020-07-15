//
//  CaseIterableFlagControl.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 14/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

struct CaseIterableFlagControl<Value>: View where Value: FlagValue, Value: CaseIterable, Value: Hashable, Value.AllCases: RandomAccessCollection {

    // MARK: - Properties

    let label: String
    @Binding var flagValue: Value
    @Binding var showDetail: Bool

    @State private var showPicker = false

    // MARK: - View Body

    var body: some View {
        VStack {
            HStack {
                Picker(self.label, selection: self.$flagValue) {
                    ForEach(Value.allCases, id: \.self) { value in
                        FlagDisplayValueView(value: value)
                    }
                }
                DetailButton(showDetail: self.$showDetail)
            }
        }
    }

}

protocol CaseIterableEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

extension UnfurledFlag: CaseIterableEditableFlag
            where Value: FlagValue, Value: CaseIterable, Value.AllCases: RandomAccessCollection,
                  Value: RawRepresentable, Value.RawValue: FlagValue, Value: Hashable {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        let binding = Binding(key: self.flag.key, manager: manager, defaultValue: self.flag.defaultValue, transformer: PassthroughTransformer<Value>.self)
        return CaseIterableFlagControl<Value>(label: label, flagValue: binding, showDetail: showDetail)
            .eraseToAnyView()
    }
}

#endif
