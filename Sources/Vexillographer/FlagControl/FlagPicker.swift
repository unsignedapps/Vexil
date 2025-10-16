import SwiftUI
import Vexil

public struct FlagPicker<Value: FlagValue, SelectionValue: Hashable, Content: View>: View {

    private var name: String
    @Binding private var value: Value
    private var selection: WritableKeyPath<Value, SelectionValue>
    private var content: Content

    init(
        configuration: FlagControlConfiguration<Value>,
        selection: WritableKeyPath<Value, SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        name = configuration.name
        _value = configuration.$value
        self.selection = selection
        self.content = content()
    }

    public var body: some View {
        Picker(name, selection: $value[dynamicMember: selection]) {
            content
        }
    }

}

public extension FlagPicker where SelectionValue == Value {

    init(configuration: FlagControlConfiguration<Value>, @ViewBuilder content: () -> Content) {
        self.init(configuration: configuration, selection: \.asSelection, content: content)
    }

}

private extension FlagValue {

    var asSelection: Self {
        get { self }
        set { self = newValue }
    }

}




public struct DefaultFlagPickerContent<SelectionValue: Hashable>: View {

    private var options: [SelectionValue]

    init(_ options: [SelectionValue]) {
        self.options = options
    }

    public var body: some View {
        ForEach(options, id: \.self) { option in
            if let optional = option as? any OptionalProtocol {
                if let wrapped = optional.wrapped {
                    Text(String(describing: wrapped))
                } else {
                    Section {
                        Text("None")
                    }
                }
            } else {
                Text(String(describing: option))
            }
        }
    }

}
