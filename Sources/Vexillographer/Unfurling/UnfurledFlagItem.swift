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

import Foundation
import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol UnfurledFlagItem {
    var id: UUID { get }
    var info: UnfurledFlagInfo { get }
    var hasChildren: Bool { get }
    var childLinks: [UnfurledFlagItem]? { get }
    var unfurledView: AnyView { get }
    var isEditable: Bool { get }
    var isLink: Bool { get }
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagItemView: View {
    var item: UnfurledFlagItem

    var body: some View {
        item.unfurledView.id(item.id)
    }
}

#endif
