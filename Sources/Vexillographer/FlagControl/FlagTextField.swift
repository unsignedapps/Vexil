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

// A text field
// - want to dismiss on scroll?
// - want to have confirm/cancel?
struct FlagTextField<Value: FlagValue>: View {

    private var name: String
    @Binding
    private var value: Value
    private var placeholder: String
    private var formatted: WritableKeyPath<Value, String>
    private var format: (String) -> String
    private var editingFormat: (String) -> String
#if os(iOS) || os(tvOS)
    private var keyboardType = UIKeyboardType.default
#endif

    @State
    private var cachedText: String?

    @FocusState
    private var isFocused

    init(
        configuration: FlagControlConfiguration<Value>,
        formatted: WritableKeyPath<Value, String>,
        placeholder: String = "",
        format: @escaping (String) -> String = { $0 },
        editingFormat: @escaping (String) -> String = { $0 }
    ) {
        self.name = configuration.name
        _value = configuration.$value
        self.placeholder = placeholder
        self.formatted = formatted
        self.format = format
        self.editingFormat = editingFormat
    }

    var body: some View {
        HStack {
            Text(name)
                .accessibilityHidden(true)
            TextField(placeholder, text: text)
                .multilineTextAlignment(.trailing)
                .accessibilityLabel(name)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .textContentType(nil)
#if os(iOS) || os(tvOS)
                .keyboardType(keyboardType)
#endif
        }
        .onChange(of: value.boxedFlagValue) { _ in
            cachedText = nil
        }
        .onChange(of: cachedText) { newText in
            guard let newText else {
                return
            }
            cachedText = editingFormat(newText)
        }
        .onChange(of: isFocused) { isFocused in
            guard isFocused == false, let cachedText else {
                return
            }
            let newText = format(cachedText)
            self.cachedText = newText
            value[keyPath: formatted] = newText
        }
        .focused($isFocused)
    }

    // Can this be computed key path?
    var text: Binding<String> {
        Binding(
            get: { cachedText ?? value[keyPath: formatted] },
            set: { cachedText = $0 }
        )
    }

#if os(iOS) || os(tvOS)
    func keyboardType(_ type: UIKeyboardType) -> Self {
        var copy = self
        copy.keyboardType = type
        return copy
    }
#endif

}
