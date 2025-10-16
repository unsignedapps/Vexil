import SwiftUI
import Vexil

extension FlagTextField where Value.BoxedValueType: BinaryFloatingPoint {

    init(configuration: FlagControlConfiguration<Value>) {
        self.init(
            configuration: configuration,
            formatted: \.asString,
            keyboardType: .decimalPad,
            editingFormat: { $0 }
        )
    }

}

private extension FlagValue where BoxedValueType: BinaryFloatingPoint {
    var asString: String {
        get {
            Double(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.double(0) : .double(Double(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}

protocol FloatingPointTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: FloatingPointTextFieldRepresentable where Value.BoxedValueType: BinaryFloatingPoint {
    func makeContent() -> any View {
        FlagTextField(configuration: self)
    }
}

extension FlagTextField {

    init<Wrapped>(configuration: FlagControlConfiguration<Wrapped?>) where Value == Wrapped?, Wrapped.BoxedValueType: BinaryFloatingPoint {
        self.init(
            configuration: configuration,
            formatted: \.asStringOrEmpty,
            keyboardType: .decimalPad,
            editingFormat: { $0 }
        )
    }

}

private extension FlagValue where BoxedValueType: OptionalProtocol, BoxedValueType.Wrapped: BinaryFloatingPoint {
    var asStringOrEmpty: String {
        get {
            Double(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .double(Double(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}

protocol OptionalFloatingPointFlagTextFieldRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalFloatingPointFlagTextFieldRepresentable where Value.BoxedValueType: OptionalProtocol, Value.BoxedValueType.Wrapped: BinaryFloatingPoint {
    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asStringOrEmpty,
            keyboardType: .decimalPad,
            editingFormat: { $0 }
        )
    }
}
