//
//  OptionalTransformer.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 26/9/20.
//

#if os(iOS) || os(macOS)

import Foundation
import Vexil

struct OptionalTransformer<Value, Default, Underlying>: BoxedFlagValueTransformer
                where Value: OptionalFlagValue, Default: OptionalDefaultValue, Underlying: BoxedFlagValueTransformer,
                      Underlying.OriginalValue == Value.WrappedFlagValue, Default == Underlying.EditingValue {
    typealias OriginalValue = Value
    typealias EditingValue = Underlying.EditingValue

    static func toEditingValue(_ value: OriginalValue?) -> EditingValue {
        guard let wrapped = value?.wrapped else { return Default.defaultValue }
        return Underlying.toEditingValue(wrapped)
    }

    static func toOriginalValue(_ value: EditingValue) -> OriginalValue? {
        return Value(Underlying.toOriginalValue(value))
    }
}

// MARK: - Default Values

protocol OptionalDefaultValue {
    static var defaultValue: Self { get }
}

#endif
