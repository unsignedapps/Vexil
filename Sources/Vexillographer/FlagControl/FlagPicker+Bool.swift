import SwiftUI
import Vexil

public extension FlagPicker where Value.BoxedValueType == Bool?, SelectionValue == Bool?, Content == DefaultFlagPickerContent<Bool?> {
    init(configuration: FlagControlConfiguration<Value>) {
        self.init(configuration: configuration, selection: \.asOptionalBool) {
            DefaultFlagPickerContent<Bool?>(Array([nil, true, false]))
        }
    }
}

private extension FlagValue where BoxedValueType == Bool? {

    var asOptionalBool: Bool? {
        get {
            Bool(boxedFlagValue: boxedFlagValue)
        }
        set {
            let boxedFlagValue = newValue.map(BoxedFlagValue.bool) ?? .none
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }

}

protocol OptionalBooleanFlagPickerRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalBooleanFlagPickerRepresentable where Value.BoxedValueType == Bool? {
    func makeContent() -> any View {
        FlagPicker(configuration: self)
    }
}
