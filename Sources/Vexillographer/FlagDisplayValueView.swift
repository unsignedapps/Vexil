//
//  FlagDisplayView.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 15/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct FlagDisplayValueView<Value>: View where Value: FlagValue {

    // MARK: - Properties

    let value: Value


    // MARK: - Body

    var body: some View {
        return (self.value as? OptionalFlagDisplayValue)?.flagDisplayText
            ?? (self.value as? FlagDisplayValue)?.flagDisplayText
            ?? Text(String(describing: self.value)).eraseToAnyView()
    }

}

private protocol OptionalFlagDisplayValue {
    var flagDisplayText: AnyView { get }
}

extension Optional: OptionalFlagDisplayValue where Wrapped: FlagValue {
    var flagDisplayText: AnyView {
        guard let value = self else {
            return Text("nil")
                .foregroundColor(.red)
                .eraseToAnyView()
        }

        let string = (value as? FlagDisplayValue)?.flagDisplayValue ?? String(describing: value)
        return Text(string)
            .eraseToAnyView()
    }
}

private extension FlagDisplayValue {
    var flagDisplayText: AnyView {
        return Text(self.flagDisplayValue)
            .eraseToAnyView()
    }
}


#endif
