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
                NavigationLink(destination: self.selector, isActive: self.$showPicker) {
                    HStack {
                        Text(self.label).font(.headline)
                        Spacer()
                        FlagDisplayValueView(value: self.flagValue)
                    }
                }
                DetailButton(showDetail: self.$showDetail)
            }
        }
    }

    #if os(iOS)

    var selector: some View {
        return self.selectorList
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text(self.label), displayMode: .inline)
    }

    #else

    var selector: some View {
        return self.selectorList
    }

    #endif

    var selectorList: some View {
        List(Value.allCases, id: \.self, selection: Binding(self.$flagValue)) { value in
            HStack {
                FlagDisplayValueView(value: value)
                Spacer()

                if value == self.flagValue {
                    if #available(OSX 11.0, *) {
                        Image(systemName: "checkmark")
                    } else {
                        Text("✓")
                    }
                }
            }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.flagValue = value
                    self.showPicker = false
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
