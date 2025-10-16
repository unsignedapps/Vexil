import SwiftUI
import Vexil

struct FlagTextField<Value: FlagValue>: View {

    private var name: String
    @Binding private var value: Value
    private var placeholder: String
    private var formatted: WritableKeyPath<Value, String>
    private var format: (String) -> String
    private var editingFormat: (String) -> String
    #if canImport(UIKit)
        private var keyboardType: UIKeyboardType
    #endif

    @State private var cachedText: String?

    @FocusState private var isFocused

    #if canImport(UIKit)
        init(
            configuration: FlagControlConfiguration<Value>,
            formatted: WritableKeyPath<Value, String>,
            keyboardType: UIKeyboardType = .default,
            placeholder: String = "",
            format: @escaping (String) -> String = { $0 },
            editingFormat: @escaping (String) -> String = { $0 }
        ) {
            self.name = configuration.name
            self._value = configuration.$value
            self.keyboardType = keyboardType
            self.placeholder = placeholder
            self.formatted = formatted
            self.format = format
            self.editingFormat = editingFormat
        }
    #else
        init(
            configuration: FlagControlConfiguration<Value>,
            formatted: WritableKeyPath<Value, String>,
            placeholder: String = "",
            format: @escaping (String) -> String = { $0 },
            editingFormat: @escaping (String) -> String = { $0 }
        ) {
            self.name = configuration.name
            self._value = configuration.$value
            self.placeholder = placeholder
            self.formatted = formatted
            self.format = format
            self.editingFormat = editingFormat
        }
    #endif

    var body: some View {
        HStack {
            Text(name)
                .accessibilityHidden(true)
            TextField(placeholder, text: text)
                .multilineTextAlignment(.trailing)
                .accessibilityLabel(name)
            #if canImport(UIKit)
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

    var text: Binding<String> {
        Binding(
            get: { cachedText ?? value[keyPath: formatted] },
            set: { cachedText = $0 }
        )
    }

}

