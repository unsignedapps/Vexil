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

#if os(iOS) || os(macOS)

import SwiftUI

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct DetailButton: View {

    // MARK: - Properties

    let hasChanges: Bool

    @Binding
    var showDetail: Bool

    @State
    private var size = CGSize.zero

    @State
    private var isDraggingInside = false

    // MARK: - View

#if os(iOS)

    var body: some View {
        Image(systemName: self.hasChanges ? "info.circle.fill" : "info.circle")
            .imageScale(.large)
            .foregroundColor(.accentColor)
            .opacity(self.isDraggingInside ? 0.3 : 1)
            .animation(self.isDraggingInside ? .easeOut(duration: 0.15) : .easeIn(duration: 0.2), value: self.isDraggingInside)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.size = size
            }
            .gesture(selectionGesture)
    }

    private var selectionGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { data in
                self.isDraggingInside = CGRect(origin: .zero, size: self.size)
                    .insetBy(dx: -10, dy: -10)
                    .contains(data.location)
            }
            .onEnded { _ in
                if self.isDraggingInside {
                    self.showDetail.toggle()
                    self.isDraggingInside = false
                }
            }
    }

#elseif os(macOS)

    var body: some View {
        EmptyView()
    }

#endif

}

private struct SizePreferenceKey: PreferenceKey {

    typealias Value = CGSize

    static var defaultValue: Value = .zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }

}

#endif
