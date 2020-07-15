//
//  FlagValueControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

extension Binding {
    init<Transformer, RootGroup> (key: String, manager: FlagValueManager<RootGroup>, defaultValue: Transformer.OriginalValue, transformer: Transformer.Type) where RootGroup: FlagContainer, Transformer: FlagValueTransformer, Transformer.EditingValue == Value {
        self.init (
            get: {
                let value: Transformer.OriginalValue = manager.flagValue(key: key) ?? defaultValue
                return transformer.toEditingValue(value)
            },
            set: { newValue in
                do {
                    let value = transformer.toOriginalValue(newValue)
                    try manager.setFlagValue(value, key: key)

                } catch {
                    print("[Vexilographer] Could not set flag with key \"\(key)\" to \"\(newValue)\"")
                }
            }
        )
    }
}


// MARK: - Flag Value Transformers

/// Describes a type that can be used to transform Flag Values for editing
///
protocol FlagValueTransformer {
    associatedtype OriginalValue: FlagValue
    associatedtype EditingValue: FlagValue

    static func toEditingValue (_ value: OriginalValue) -> EditingValue
    static func toOriginalValue (_ value: EditingValue) -> OriginalValue?
}

/// A simple transformer that passes the value through as the same type
///
struct PassthroughTransformer<Value>: FlagValueTransformer where Value: FlagValue {
    typealias OriginalValue = Value
    typealias EditingValue = Value

    static func toEditingValue(_ value: OriginalValue) -> Value {
        return value
    }

    static func toOriginalValue(_ value: Value) -> OriginalValue? {
        return value
    }
}

/// A simple transformer that converts a FlagValue into a string for editing with a TextField
///
struct LosslessStringTransformer<Value>: FlagValueTransformer where Value: FlagValue, Value: LosslessStringConvertible {
    typealias OriginalValue = Value
    typealias EditingValue = String

    static func toEditingValue(_ value: Value) -> String {
        value.description
    }

    static func toOriginalValue(_ value: String) -> Value? {
        Value(value)
    }
}

#endif
