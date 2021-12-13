//
//  BooleanFlagControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

// Boolean Flags
//
// Boolean flags are those those whose boxed type is `Bool`, or `Bool?`
//
// This includes `Bool` directly, but also `Optional<Bool>` and
// `RawRepresentable where RawValue == Bool`.
//
// Plus any custom types that are boxed to a Bool.

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct BooleanFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var value: Bool

    let hasChanges: Bool
    let isEditable: Bool
    @Binding var showDetail: Bool


    // MARK: - Views

    var body: some View {
        HStack {
            if self.isEditable {
                Toggle(self.label, isOn: self.$value)
            } else {
                Text(self.label).font(.headline)
                Spacer()
                FlagDisplayValueView(value: self.value)
            }
            DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
        }
    }
}


// MARK: - Boolean Flags

/// Support for `UnfurledFlag` when `FlagValue.BoxedValueType == Bool`
///
@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol BooleanEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: BooleanEditableFlag where Value.BoxedValueType == Bool {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return BooleanFlagControl (
            label: label,
            value: Binding (
                key: self.info.key,
                manager: manager,
                defaultValue: self.flag.defaultValue,
                transformer: BoxedPassthroughTransformer.self
            ),
            hasChanges: manager.hasValueInSource(flag: self.flag),
            isEditable: manager.isEditable,
            showDetail: showDetail
        )
            .eraseToAnyView()
    }
}

// MARK: - Optional Boolean Flags

/// Support for `UnfurledFlag` when `FlagValue.BoxedFlagValue == Bool?`
///
@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol OptionalBooleanEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: OptionalBooleanEditableFlag where Value: FlagValue, Value.BoxedValueType: OptionalFlagValue, Value.BoxedValueType.WrappedFlagValue == Bool {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return BooleanFlagControl (
            label: label,
            value: Binding (
                key: self.flag.key,
                manager: manager,
                defaultValue: self.flag.defaultValue,
                transformer: OptionalTransformer<Value.BoxedValueType, Bool, BoxedPassthroughTransformer>.self
            ),
            hasChanges: manager.hasValueInSource(flag: self.flag),
            isEditable: manager.isEditable,
            showDetail: showDetail
        )
            .eraseToAnyView()
    }
}

extension Bool: OptionalDefaultValue {
    static var defaultValue: Bool {
        return false
    }
}

#endif
