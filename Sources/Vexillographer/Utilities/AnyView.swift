//
//  AnyView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if !os(Linux)

import SwiftUI

extension View {
    func eraseToAnyView () -> AnyView {
        return AnyView(self)
    }
}

#endif
