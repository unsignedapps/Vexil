//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

// Case Iterable Flags
//
// Case Iterable flags are those those whose flag value conforms to `CaseIterable`

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct CaseIterableFlagControl<Value>: View where Value: FlagValue, Value: CaseIterable, Value: Hashable, Value.AllCases: RandomAccessCollection {

    // MARK: - Properties

    let label: String
    @Binding
    var value: Value

    let hasChanges: Bool
    let isEditable: Bool
    @Binding
    var showDetail: Bool

    // MARK: - View Body

    var content: some View {
        HStack {
            Text(self.label).font(.headline)
            Spacer()
            FlagDisplayValueView(value: self.value)
        }
    }

#if os(iOS)

    var body: some View {
        HStack {
            if self.isEditable {
                NavigationLink(destination: self.selector) {
                    self.content
                }
            } else {
                self.content
            }
            DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
        }
    }

    var selector: some View {
        SelectorList(value: self.$value)
            .navigationBarTitle(Text(self.label), displayMode: .inline)
    }

#elseif os(macOS)

    var body: some View {
        Group {
            if self.isEditable {
                self.picker
            } else {
                self.content
            }
        }
    }

    var picker: some View {
        let picker = Picker(
            selection: self.$value,
            label: Text(self.label),
            content: {
                ForEach(Value.allCases, id: \.self) { value in
                    FlagDisplayValueView(value: value)
                }
            }
        )

#if compiler(>=5.3.1)

        return picker
            .pickerStyle(MenuPickerStyle())

#else

        return picker

#endif
    }

#endif

    struct SelectorList: View {
        @Binding var value: Value

        @Environment(\.presentationMode) private var presentationMode

        var body: some View {
            Form {
                ForEach(Value.allCases, id: \.self) { value in
                    Button(
                        action: {
                            self.value = value
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            HStack {
                                FlagDisplayValueView(value: value)
                                    .foregroundColor(.primary)
                                Spacer()

                                if value == self.value {
                                    self.checkmark
                                }
                            }
                        }
                    )
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
}

// MARK: - Creating CaseIterableFlagControls

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol CaseIterableEditableFlag {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: CaseIterableEditableFlag
    where Value: FlagValue, Value: CaseIterable, Value.AllCases: RandomAccessCollection,
    Value: RawRepresentable, Value.RawValue: FlagValue, Value: Hashable
{
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return CaseIterableFlagControl<Value>(
            label: label,
            value: Binding(
                key: flag.key,
                manager: manager,
                defaultValue: flag.defaultValue,
                transformer: PassthroughTransformer<Value>.self
            ),
            hasChanges: manager.hasValueInSource(flag: flag),
            isEditable: manager.isEditable,
            showDetail: showDetail
        )
        .eraseToAnyView()
    }
}

#endif
