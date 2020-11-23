//
//  CopyButton.swift
//  Vexil: Vexillographer
//
//  Created by Rod Brown on 15/11/20.
//

#if os(iOS) || os(macOS)

import SwiftUI

struct CopyButton: View {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        #if compiler(>=5.3.1)
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return Button(action: self.action) {
                Label("Copy", systemImage: "doc.on.doc")
            }.eraseToAnyView()
        }
        #endif
        return Button("Copy", action: self.action)
            .eraseToAnyView()
    }

}

#endif
