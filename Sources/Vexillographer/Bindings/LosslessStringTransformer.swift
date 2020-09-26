//
//  LosslessStringTransformer.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 26/9/20.
//

#if os(iOS) || os(macOS)

import Foundation
import Vexil

/// A simple transformer that converts a FlagValue into a string for editing with a TextField
///
struct LosslessStringTransformer<Value>: BoxedFlagValueTransformer where Value: LosslessStringConvertible {
    typealias OriginalValue = Value
    typealias EditingValue = String

    static func toEditingValue(_ value: Value?) -> String {
        value!.description
    }

    static func toOriginalValue(_ value: String) -> Value? {
        Value(value)
    }
}

#endif
