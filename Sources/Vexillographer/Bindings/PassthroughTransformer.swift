//
//  PassthroughTransformer.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 26/9/20.
//

#if os(iOS) || os(macOS)

import Foundation
import Vexil

/// A simple transformer that passes the value through as the same type
///
struct BoxedPassthroughTransformer<Value>: BoxedFlagValueTransformer {
    typealias OriginalValue = Value
    typealias EditingValue = Value

    static func toEditingValue(_ value: OriginalValue?) -> Value {
        return value!
    }

    static func toOriginalValue(_ value: Value) -> OriginalValue? {
        return value
    }
}

struct PassthroughTransformer<Value>: FlagValueTransformer where Value: FlagValue {
    typealias OriginalValue = Value
    typealias EditingValue = Value

    static func toEditingValue(_ value: OriginalValue?) -> Value {
        return value!
    }

    static func toOriginalValue(_ value: Value) -> OriginalValue? {
        return value
    }
}

#endif
