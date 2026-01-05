//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI

// UI helper
struct RowContent<Content: View>: View {

    var label: String
    var content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    init(_ label: String, value: some Any) where Content == Text {
        self.label = label
        self.content = Text(String(describing: value))
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
            Spacer()
            content
                .foregroundStyle(.secondary)
        }
    }

}
