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

    @Binding
    var showPicker: Bool

    // MARK: - View Body

    var content: some View {
        HStack {
            Text(label).font(.headline)
            Spacer()
            FlagDisplayValueView(value: value)
        }
    }

#if os(iOS)

    var body: some View {
        HStack {
            if isEditable {
                NavigationLink(destination: selector, isActive: $showPicker) {
                    content
                }
            } else {
                content
            }
            DetailButton(hasChanges: hasChanges, showDetail: $showDetail)
        }
    }

    var selector: some View {
        selectorList
            .navigationBarTitle(Text(label), displayMode: .inline)
    }

#elseif os(macOS)

    var body: some View {
        Group {
            if isEditable {
                picker
            } else {
                content
            }
        }
    }

    var picker: some View {
        let picker = Picker(
            selection: $value,
            label: Text(label),
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

    var selectorList: some View {
        Form {
            ForEach(Value.allCases, id: \.self) { value in
                Button(
                    action: {
                        self.value = value
                        showPicker = false
                    },
                    label: {
                        HStack {
                            FlagDisplayValueView(value: value)
                                .foregroundColor(.primary)
                            Spacer()

                            if value == self.value {
                                checkmark
                            }
                        }
                    }
                )
            }
        }
    }

#if os(macOS)

    var checkmark: some View {
        Text("✓")
    }

#else

    var checkmark: some View {
        Image(systemName: "checkmark")
    }

#endif

}


// MARK: - Creating CaseIterableFlagControls

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol CaseIterableEditableFlag {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>, showPicker: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: CaseIterableEditableFlag
    where Value: FlagValue, Value: CaseIterable, Value.AllCases: RandomAccessCollection,
    Value: RawRepresentable, Value.RawValue: FlagValue, Value: Hashable
{
    func control(label: String, manager: FlagValueManager<some FlagContainer>, showDetail: Binding<Bool>, showPicker: Binding<Bool>) -> AnyView {
        CaseIterableFlagControl<Value>(
            label: label,
            value: Binding(
                key: flag.key,
                manager: manager,
                defaultValue: flag.defaultValue,
                transformer: PassthroughTransformer<Value>.self
            ),
            hasChanges: manager.hasValueInSource(flag: flag),
            isEditable: manager.isEditable,
            showDetail: showDetail,
            showPicker: showPicker
        )
        .eraseToAnyView()
    }
}

#endif
