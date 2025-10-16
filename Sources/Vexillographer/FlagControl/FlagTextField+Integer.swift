import SwiftUI
import Vexil

extension FlagTextField where Value.BoxedValueType: BinaryInteger {

    init(configuration: FlagControlConfiguration<Value>) {
        self.init(
            configuration: configuration,
            formatted: \.asString,
            keyboardType: .numberPad,
            editingFormat: { $0.filter(\.isNumber) }
        )
    }

}

private extension FlagValue where BoxedValueType: BinaryInteger {
    var asString: String {
        get {
            Int(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.integer(0) : .integer(Int(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}

protocol IntegerFlagTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: IntegerFlagTextFieldRepresentable where Value.BoxedValueType: BinaryInteger {
    func makeContent() -> any View {
        FlagTextField(configuration: self)
    }
}

extension FlagTextField {

    init<Wrapped>(configuration: FlagControlConfiguration<Wrapped?>) where Value == Wrapped?, Wrapped.BoxedValueType: BinaryInteger {
        self.init(
            configuration: configuration,
            formatted: \.asStringOrEmpty,
            keyboardType: .numberPad,
            editingFormat: { $0.filter(\.isNumber) }
        )
    }

}

private extension FlagValue where BoxedValueType: OptionalProtocol, BoxedValueType.Wrapped: BinaryInteger {
    var asStringOrEmpty: String {
        get {
            Int(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .integer(Int(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}

protocol OptionalIntegerFlagTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalIntegerFlagTextFieldRepresentable where Value.BoxedValueType: OptionalProtocol, Value.BoxedValueType.Wrapped: BinaryInteger {
    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asStringOrEmpty,
            keyboardType: .numberPad,
            editingFormat: { $0.filter(\.isNumber) }
        )
    }
}
