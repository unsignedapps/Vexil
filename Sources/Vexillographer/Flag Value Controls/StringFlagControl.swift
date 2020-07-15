//
//  BooleanFlagControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

struct StringFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var flagValue: String
    @Binding var showDetail: Bool

    #if os(iOS)
    let keyboardType: UIKeyboardType
    #endif


    // MARK: - Views

    var body: some View {
        HStack {
            Text(self.label)
            Spacer()
            self.textField
            DetailButton(showDetail: self.$showDetail)
        }
    }


    #if os(iOS)

    var textField: some View {
        TextField("", text: self.$flagValue)
            .multilineTextAlignment(.trailing)
            .keyboardType(self.keyboardType)
    }

    #elseif os(macOS)

    var textField: some View {
        TextField("", text: self.$flagValue)
            .multilineTextAlignment(.trailing)
    }

    #endif
}


// MARK: - Flag Control

protocol StringEditableFlag {
    func control<RootGroup> (label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> StringFlagControl where RootGroup: FlagContainer
}

#if os(macOS)

extension UnfurledFlag: StringEditableFlag where Value: LosslessStringConvertible {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> StringFlagControl where RootGroup: FlagContainer {
        return StringFlagControl (
            label: label,
            flagValue: Binding(key: self.flag.key, manager: manager, defaultValue: self.flag.defaultValue, transformer: LosslessStringTransformer<Value>.self),
            showDetail: showDetail
        )
    }
}

#elseif os(iOS)

extension UnfurledFlag: StringEditableFlag where Value: LosslessStringConvertible {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>) -> StringFlagControl where RootGroup: FlagContainer {
        return StringFlagControl (
            label: label,
            flagValue: Binding(key: self.flag.key, manager: manager, defaultValue: self.flag.defaultValue, transformer: LosslessStringTransformer<Value>.self),
            showDetail: showDetail,
            keyboardType: Value.keyboardType
        )
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
         || Self.self == UInt64.self {
            return .numberPad
        }

        return .default
    }
}

#endif

#endif
