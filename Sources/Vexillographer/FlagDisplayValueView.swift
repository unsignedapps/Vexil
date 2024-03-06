//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS) || os(visionOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct FlagDisplayValueView<Value>: View where Value: FlagValue {

    // MARK: - Properties

    let value: Value

    var string: String? {
        if let value = value as? OptionalFlagDisplayValue {
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
