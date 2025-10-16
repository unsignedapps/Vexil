import SwiftUI
import Vexil

extension FlagTextField where Value.BoxedValueType == String {

    init(configuration: FlagControlConfiguration<Value>) {
        self.init(configuration: configuration, formatted: \.asString)
    }

}

private extension FlagValue where BoxedValueType == String {
    var asString: String {
        get {
            String(boxedFlagValue: boxedFlagValue) ?? ""
        }
        set {
            self = Self(boxedFlagValue: .string(newValue)) ?? self
        }
    }
}

protocol StringFlagTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: StringFlagTextFieldRepresentable where Value.BoxedValueType == String {
    func makeContent() -> any View {
        FlagTextField(configuration: self)
    }
}

extension FlagTextField {

    init(configuration: FlagControlConfiguration<Value>) where Value.BoxedValueType == String? {
        self.init(configuration: configuration, formatted: \.asStringOrEmpty, placeholder: "nil")
    }

}

private extension FlagValue where BoxedValueType == String? {
    var asStringOrEmpty: String {
        get {
            String(boxedFlagValue: boxedFlagValue) ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .string(newValue)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}

protocol OptionalStringFlagTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalStringFlagTextFieldRepresentable where Value.BoxedValueType == String? {
    func makeContent() -> any View {
        FlagTextField(configuration: self)
    }
}
