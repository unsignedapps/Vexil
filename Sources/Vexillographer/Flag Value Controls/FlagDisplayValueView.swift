//
//  FlagDisplayView.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 15/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

struct FlagDisplayValueView<Value>: View where Value: FlagValue {

    // MARK: - Properties

    let value: Value


    // MARK: - Body

    var body: some View {
        if let value = self.value as? FlagDisplayValue {
            return Text(value.flagDisplayValue)

        } else {
            return Text(String(describing: self.value).displayName)
        }
    }

}

#endif
