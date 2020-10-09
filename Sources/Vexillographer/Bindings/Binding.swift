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
    @available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
    init<Transformer, RootGroup, FValue> (key: String, manager: FlagValueManager<RootGroup>, defaultValue: FValue, transformer: Transformer.Type) where RootGroup: FlagContainer, Transformer: BoxedFlagValueTransformer, FValue: FlagValue, Transformer.EditingValue == Value, FValue.BoxedValueType == Transformer.OriginalValue {
        self.init (
            get: {
                let value: FValue.BoxedValueType? = manager.boxedValue(key: key, type: FValue.self) ?? defaultValue.unwrappedBoxedValue()
                return transformer.toEditingValue(value)
            },
            set: { newValue in
                do {
                    let value = transformer.toOriginalValue(newValue)
                    try manager.setBoxedValue(value, type: FValue.self, key: key)

                } catch {
                    print("[Vexilographer] Could not set flag with key \"\(key)\" to \"\(newValue)\"")
                }
            }
        )
    }

    @available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
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

/// Describes a type that can be used to transform Boxed Flag Values for editing
///
protocol BoxedFlagValueTransformer {
    associatedtype OriginalValue
    associatedtype EditingValue

    static func toEditingValue (_ value: OriginalValue?) -> EditingValue
    static func toOriginalValue (_ value: EditingValue) -> OriginalValue?
}

/// Describes a type that can be used to transform Flag Values for editing
///
protocol FlagValueTransformer {
    associatedtype OriginalValue: FlagValue
    associatedtype EditingValue: FlagValue

    static func toEditingValue (_ value: OriginalValue?) -> EditingValue
    static func toOriginalValue (_ value: EditingValue) -> OriginalValue?
}

#endif
