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

struct BooleanFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var value: Bool

    let hasChanges: Bool
    @Binding var showDetail: Bool


    // MARK: - Views

    var body: some View {
        HStack {
            Toggle(self.label, isOn: self.$value)
            DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
        }
    }
}


// MARK: - Boolean Flags

/// Support for `UnfurledFlag` when `FlagValue.BoxedValueType == Bool`
///
protocol BooleanEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

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
            showDetail: showDetail
        )
            .eraseToAnyView()
    }
}

// MARK: - Optional Boolean Flags

/// Support for `UnfurledFlag` when `FlagValue.BoxedFlagValue == Bool?`
///
protocol OptionalBooleanEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

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
