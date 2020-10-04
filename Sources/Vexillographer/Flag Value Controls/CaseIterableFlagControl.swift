//
//  CaseIterableFlagControl.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 14/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

// Case Iterable Flags
//
// Case Iterable flags are those those whose flag value conforms to `CaseIterable`

struct CaseIterableFlagControl<Value>: View where Value: FlagValue, Value: CaseIterable, Value: Hashable, Value.AllCases: RandomAccessCollection {

    // MARK: - Properties

    let label: String
    @Binding var value: Value

    let hasChanges: Bool
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
                        FlagDisplayValueView(value: self.value)
                    }
                }
                DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
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
        List(Value.allCases, id: \.self, selection: Binding(self.$value)) { value in
            HStack {
                FlagDisplayValueView(value: value)
                Spacer()

                if value == self.value {
                    self.checkmark
                }
            }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.value = value
                    self.showPicker = false
                }
        }
    }

    #if os(macOS)

    var checkmark: some View {
        return Text("✓")
    }

    #else

    var checkmark: some View {
        return Image(systemName: "checkmark")
    }

    #endif

}


// MARK: - Creating CaseIterableFlagControls

protocol CaseIterableEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

extension UnfurledFlag: CaseIterableEditableFlag
            where Value: FlagValue, Value: CaseIterable, Value.AllCases: RandomAccessCollection,
                  Value: RawRepresentable, Value.RawValue: FlagValue, Value: Hashable {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return CaseIterableFlagControl<Value> (
            label: label,
            value: Binding (
                key: self.flag.key,
                manager: manager,
                defaultValue: self.flag.defaultValue,
                transformer: PassthroughTransformer<Value>.self
            ),
            hasChanges: manager.hasValueInSource(flag: self.flag),
            showDetail: showDetail
        )
            .eraseToAnyView()
    }
}

#endif
