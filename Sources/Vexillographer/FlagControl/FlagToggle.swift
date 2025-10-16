import SwiftUI
import Vexil

public struct FlagToggle<Value: FlagValue>: View where Value.BoxedValueType == Bool {

    private var name: String
    @Binding private var value: Value

    public init(configuration: FlagControlConfiguration<Value>) {
        self.name = configuration.name
        _value = configuration.$value
    }

    public var body: some View {
        Toggle(name, isOn: $value.asBool)
    }

}

private extension FlagValue where BoxedValueType == Bool {

    var asBool: Bool {
        get {
            Bool(boxedFlagValue: boxedFlagValue) ?? false
        }
        set {
            self = Self(boxedFlagValue: .bool(newValue)) ?? self
        }
    }

}

protocol FlagToggleRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: FlagToggleRepresentable where Value.BoxedValueType == Bool {
    func makeContent() -> any View {
        FlagToggle(configuration: self)
    }
}
