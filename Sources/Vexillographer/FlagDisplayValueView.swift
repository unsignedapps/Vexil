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

    var string: String? {
        if let value = self.value as? OptionalFlagDisplayValue {
            return value.flagDisplayValue
        }
        if let displayValue = value as? FlagDisplayValue {
            return displayValue.flagDisplayValue
        }
        return String(describing: value)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if self.string != nil {
                Text(string!)
                    .contextMenu {
                        CopyButton(action: self.string!.copyToPasteboard)
                    }

            } else {
                Text("nil").foregroundColor(.red)
            }
        }
    }

}

private protocol OptionalFlagDisplayValue {
    var flagDisplayValue: String? { get }
}

extension Optional: OptionalFlagDisplayValue where Wrapped: FlagValue {
    var flagDisplayValue: String? {
        guard let value = self else {
            return nil
        }

        if let displayValue = value as? FlagDisplayValue {
            return displayValue.flagDisplayValue
        }

        return String(describing: value)
    }
}

#endif
