//
//  BooleanFlagControl.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

import SwiftUI
import Vexil

struct BooleanFlagControl: View {

    // MARK: - Properties

    let label: String
    @Binding var flagValue: Bool


    // MARK: - Views

    var body: some View {
        Toggle(self.label, isOn: self.$flagValue)
    }
}
