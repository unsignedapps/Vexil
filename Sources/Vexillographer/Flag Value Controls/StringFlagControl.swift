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

// String Flag Values
//
// String flag values are ones whose flag value conforms to `LosslessStringConvertible`

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct StringFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding
    var value: String

    let hasChanges: Bool
    let isEditable: Bool
    @Binding
    var showDetail: Bool


    // MARK: - Views

    var body: some View {
        HStack {
            Text(self.label)
            Spacer()
            if self.isEditable {
                TextField("", text: self.$value)
                    .multilineTextAlignment(.trailing)
            } else {
                FlagDisplayValueView(value: self.value)
            }
            DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
        }
    }
}


// MARK: - Lossless String Convertible Flags

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol StringEditableFlag {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: StringEditableFlag where Value.BoxedValueType: LosslessStringConvertible {

    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return StringFlagControl(
            label: label,
            value: Binding(
                key: flag.key,
                manager: manager,
                defaultValue: flag.defaultValue,
                transformer: LosslessStringTransformer<Value.BoxedValueType>.self
            ),
            hasChanges: manager.hasValueInSource(flag: flag),
            isEditable: manager.isEditable,
            showDetail: showDetail
        )
        .flagValueKeyboard(type: Value.self)
        .eraseToAnyView()
    }

}


// MARK: - Optional Lossless String Convertible Flags

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol OptionalStringEditableFlag {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: OptionalStringEditableFlag
    where Value: FlagValue, Value.BoxedValueType: OptionalFlagValue, Value.BoxedValueType.WrappedFlagValue: LosslessStringConvertible
{

    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        return StringFlagControl(
            label: label,
            value: Binding(
                key: flag.key,
                manager: manager,
                defaultValue: flag.defaultValue,
                transformer: OptionalTransformer<Value.BoxedValueType, String, LosslessStringTransformer<Value.BoxedValueType.WrappedFlagValue>>.self
            ),
            hasChanges: manager.hasValueInSource(flag: flag),
            isEditable: manager.isEditable,
            showDetail: showDetail
        )
        .flagValueKeyboard(type: Value.self)
        .eraseToAnyView()
    }

}

extension String: OptionalDefaultValue {
    var unwrapped: String? {
        self
    }

    static var defaultValue: String {
        return ""
    }
}

#if os(iOS)

private extension View {
    func flagValueKeyboard<Value>(type: Value.Type) -> some View where Value: FlagValue {
        return keyboardType(Value.keyboardType)
    }
}

private extension FlagValue {

    /// Provides a hint as to what keyboard type to use for a given FlagValue
    ///
    static var keyboardType: UIKeyboardType {
        if Self.self == Double.self || Self.self == Float.self {
            return .decimalPad

        } else if Self.self == Int.self || Self.self == Int8.self || Self.self == Int16.self
            || Self.self == Int32.self || Self.self == Int64.self || Self.self == UInt.self
            || Self.self == UInt8.self || Self.self == UInt16.self || Self.self == UInt32.self
            || Self.self == UInt64.self
        {
            return .numberPad
        }

        return .default
    }
}

#else

private extension View {
    func flagValueKeyboard<Value>(type: Value.Type) -> some View where Value: FlagValue {
        return self
    }
}

#endif

#endif
