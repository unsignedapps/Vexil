import SwiftUI
import Vexil

public extension FlagPicker where Value: CaseIterable, SelectionValue == Value, Content == DefaultFlagPickerContent<Value> {

    init(configuration: FlagControlConfiguration<Value>) {
        self.init(configuration: configuration) {
            DefaultFlagPickerContent(Array(Value.allCases))
        }
    }
}

public extension FlagPicker {

    init<Wrapped: CaseIterable & Hashable>(
        configuration: FlagControlConfiguration<Value>
    ) where Value == Wrapped?, SelectionValue == Wrapped?, Content == DefaultFlagPickerContent<Wrapped?> {
        self.init(configuration: configuration, selection: \.wrapped) {
            DefaultFlagPickerContent([nil as Wrapped?] + Array(Wrapped.allCases))
        }
    }
}

protocol CaseIterableFlagPickerRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: CaseIterableFlagPickerRepresentable where Value: CaseIterable & Hashable {
    func makeContent() -> any View {
        FlagPicker(configuration: self)
    }
}

protocol OptionalCaseIterableFlagPickerRepresentable {
    @MainActor func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalCaseIterableFlagPickerRepresentable where Value: OptionalProtocol, Value.Wrapped: CaseIterable & Hashable {
    func makeContent() -> any View {
        FlagPicker(configuration: self, selection: \.wrapped) {
            DefaultFlagPickerContent([nil as Value.Wrapped?] + Array(Value.Wrapped.allCases))
        }
    }
}
