//
//  DetailButton.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 15/7/20.
//

#if os(iOS) || os(macOS)

import SwiftUI

struct DetailButton: View {

    // MARK: - Properties

    let hasChanges: Bool
    @Binding var showDetail: Bool


    // MARK: - View

#if os(iOS)

    var body: some View {
        Button (
            action: {},
            label: { Image(systemName: self.hasChanges ? "info.circle.fill" : "info.circle") }
        )
            .onTapGesture { self.showDetail.toggle() }
    }

#elseif os(macOS)

    var body: some View {
        EmptyView()
    }

#endif

}

#endif
