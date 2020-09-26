//
//  CaseIterableFlagControl.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 14/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

// Optional Case Iterable Flags
//
// For those whose flag value is optional and conform to `CaseIterable`


struct OptionalCaseIterableFlagControl<Value>: View
            where Value: OptionalFlagValue, Value.WrappedFlagValue: CaseIterable,
                  Value.WrappedFlagValue: Hashable, Value.WrappedFlagValue.AllCases: RandomAccessCollection {

    // MARK: - Properties

    let label: String
    @Binding var value: Value
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
                        FlagDisplayValueView(value: self.value.wrapped)
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
        List {
            Section {
                HStack {
                    Text("None")
                    Spacer()

                    if self.value.wrapped == nil {
                        self.checkmark
                    }
                }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.value.wrapped = nil
                        self.showPicker = false
                    }
            }

            ForEach(Value.WrappedFlagValue.allCases, id: \.self) { value in
                HStack {
                    FlagDisplayValueView(value: value)
                    Spacer()

                    if value == self.value.wrapped {
                        self.checkmark
                    }
                }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.value.wrapped = value
                        self.showPicker = false
                    }
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

protocol OptionalCaseIterableEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

extension UnfurledFlag: OptionalCaseIterableEditableFlag
                where Value: OptionalFlagValue, Value.WrappedFlagValue: CaseIterable,
                      Value.WrappedFlagValue.AllCases: RandomAccessCollection, Value.WrappedFlagValue: RawRepresentable,
                      Value.WrappedFlagValue.RawValue: FlagValue, Value.WrappedFlagValue: Hashable {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        let key = self.info.key

        return OptionalCaseIterableFlagControl<Value> (
            label: label,
            value: Binding (
                get: { Value(manager.rawValue(key: key)) },
                set: { newValue in
                    do {
                        try manager.setFlagValue(newValue.wrapped, key: key)

                    } catch {
                        print("[Vexilographer] Could not set flag with key \"\(key)\" to \"\(newValue)\"")
                    }
                }
            ),
            showDetail: showDetail
        )
            .eraseToAnyView()
    }
}

#endif
