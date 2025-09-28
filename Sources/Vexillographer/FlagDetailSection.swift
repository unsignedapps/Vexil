//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS)

import SwiftUI

struct FlagDetailSection<Header, Content>: View where Header: View, Content: View {

    private let header: Header

    private let content: Content

    init(header: Header, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }

#if os(macOS)

    var body: some View {
        GroupBox(label: header) {
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.bottom, 8)
    }

#else

    var body: some View {
        Section(header: header) {
            content
        }
    }

#endif

}

#endif
