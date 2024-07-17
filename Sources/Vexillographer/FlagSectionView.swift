//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagSectionView<Group, Root>: View where Group: FlagContainer, Root: FlagContainer {

    // MARK: - Properties

    let group: UnfurledFlagGroup<Group, Root>
    @ObservedObject
    var manager: FlagValueManager<Root>


    // MARK: - Initialisation

    init(group: UnfurledFlagGroup<Group, Root>, manager: FlagValueManager<Root>) {
        self.group = group
        self.manager = manager
    }


    // MARK: - View Body

#if os(macOS)

    var body: some View {
        GroupBox(
            label: Text(group.info.name),
            content: {
                VStack(alignment: .leading) {
                    Text(group.info.description)
                    Divider()
                    content
                }.padding(4)
            }
        )
        .padding([.top, .bottom])
    }

#else

    var body: some View {
        Section(
            header: Text(group.info.name),
            footer: Text(group.info.description),
            content: {
                content
            }
        )
    }

#endif

    private var content: some View {
        ForEach(group.allItems(), id: \.id) { item in
            UnfurledFlagItemView(item: item)
        }
    }

}

#endif
