//
//  EditableBoxedFlagValues.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 26/9/20.
//

#if os(iOS) || os(macOS)

import Foundation
import Vexil

extension FlagValue {

    /// Casts a value to its BoxedValueType
    ///
    func unwrappedBoxedValue() -> BoxedValueType? {
        let boxed = self.boxedFlagValue

        switch boxed {
        case let .bool(value):          return value as? BoxedValueType
        case let .data(value):          return value as? BoxedValueType
        case let .double(value):        return value as? BoxedValueType
        case let .float(value):         return value as? BoxedValueType
        case let .integer(value):       return value as? BoxedValueType
        case let .string(value):        return value as? BoxedValueType

        case .none:                     return Optional<BoxedValueType>.none

        // unsupported
        case .array, .dictionary:       return nil
        }
    }

    /// Initialises a FlagValue from its BoxedValueType
    ///
    init? (unwrapped value: BoxedValueType) {

        if BoxedValueType.self == Bool.self || BoxedValueType.self == Optional<Bool>.self, let wrapped = value as? Bool {
            self.init(boxedFlagValue: .bool(wrapped))

        } else if BoxedValueType.self == Data.self || BoxedValueType.self == Optional<Data>.self, let wrapped = value as? Data {
            self.init(boxedFlagValue: .data(wrapped))

        } else if BoxedValueType.self == Double.self || BoxedValueType.self == Optional<Double>.self, let wrapped = value as? Double {
            self.init(boxedFlagValue: .double(wrapped))

        } else if BoxedValueType.self == Float.self || BoxedValueType.self == Optional<Float>.self, let wrapped = value as? Float {
            self.init(boxedFlagValue: .float(wrapped))

        } else if BoxedValueType.self == Int.self || BoxedValueType.self == Optional<Int>.self, let wrapped = value as? Int {
            self.init(boxedFlagValue: .integer(wrapped))

        } else if BoxedValueType.self == String.self || BoxedValueType.self == Optional<String>.self, let wrapped = value as? String {
            self.init(boxedFlagValue: .string(wrapped))

        } else {
            return nil
        }
    }
}

#endif
