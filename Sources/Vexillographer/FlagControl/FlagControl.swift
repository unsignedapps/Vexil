//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Vexil

// Public way to create single custom controls
public struct FlagControl<Value: FlagValue, Content: View>: View {

    private var wigwag: FlagWigwag<Value>
    private var content: (FlagControlConfiguration<Value>) -> Content

    @State
    private var cachedValue: Value?
    @State
    private var seed = 0

    @Environment(\.flagPoleContext)
    private var flagPoleContext

    public init(
        _ wigwag: FlagWigwag<Value>,
        @ViewBuilder content: @escaping (FlagControlConfiguration<Value>) -> Content
    ) {
        self.wigwag = wigwag
        self.content = content
    }

    public var body: some View {
        content(
            FlagControlConfiguration(
                seed: seed,
                name: wigwag.name,
                description: wigwag.description,
                keyPath: wigwag.keyPath,
                isEditable: flagPoleContext.editableSource != nil,
                hasValue: editableValue != nil,
                defaultValue: wigwag.defaultValue,
                value: Binding(get: getValue, set: setValue),
                resetValue: resetValue
            )
        )
        .task {
            for await _ in wigwag.changes {
                seed += 1
                cachedValue = resolvedValue
            }
        }
    }

    private var editableValue: Value? {
        flagPoleContext.editableSource?.flagValue(key: wigwag.key)
    }

    private var nonEditableValue: Value {
        let editableSourceID = flagPoleContext.editableSource?.flagValueSourceID
        for source in flagPoleContext.sources where source.flagValueSourceID != editableSourceID {
            if let value = source.flagValue(key: wigwag.key) as Value? {
                return value
            }
        }
        return wigwag.defaultValue
    }

    private var resolvedValue: Value {
        editableValue ?? nonEditableValue
    }

    private func getValue() -> Value {
        cachedValue ?? resolvedValue
    }

    private func setValue(_ newValue: Value, transaction: Transaction) {
        // TODO: logging
        guard let editableSource = flagPoleContext.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }

        do {
            $cachedValue.transaction(transaction).wrappedValue = newValue
            try editableSource.setFlagValue(newValue, key: wigwag.key)
        } catch {
            print("Error trying to set value.")
        }
    }

    private func resetValue() {
        guard let editableSource = flagPoleContext.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }

        do {
            cachedValue = nonEditableValue
            try editableSource.setFlagValue(nil as Value?, key: wigwag.key)
        } catch {
            print("Error trying to reset value.")
        }
    }

}
