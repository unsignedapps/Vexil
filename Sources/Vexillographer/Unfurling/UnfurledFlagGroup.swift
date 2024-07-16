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

import Foundation
import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagGroup<Group, Root>: UnfurledFlagItem, Identifiable where Group: FlagContainer, Root: FlagContainer {

    // MARK: - Properties

    let info: UnfurledFlagInfo
    let group: FlagGroup<Group>
    let hasChildren = true

    private let manager: FlagValueManager<Root>

    var id: UUID {
        group.id
    }

    var isEditable: Bool {
        allItems()
            .isEmpty == false
    }

    var isLink: Bool {
        group.display == .navigation
    }

    var childLinks: [UnfurledFlagItem]? {
        let children = allItems().filter { $0.hasChildren == true && $0.isLink }
        return children.isEmpty == false ? children : nil
    }

    // MARK: - Initialisation

    init(name: String, group: FlagGroup<Group>, manager: FlagValueManager<Root>) {
        self.info = UnfurledFlagInfo(key: "", info: group.info, defaultName: name)
        self.group = group
        self.manager = manager
    }


    // MARK: - Unfurled Flag Item Conformance

    func allItems() -> [UnfurledFlagItem] {
        Mirror(reflecting: group.wrappedValue)
            .children
            .compactMap { child -> UnfurledFlagItem? in
                guard let label = child.label, let unfurlable = child.value as? Unfurlable else {
                    return nil
                }
                guard let unfurled = unfurlable.unfurl(label: label, manager: manager) else {
                    return nil
                }
                return unfurled.isEditable ? unfurled : nil
            }
    }

    var unfurledView: AnyView {
        switch group.display {
        case .navigation:
            unfurledNavigationLink

        case .section:
            UnfurledFlagSectionView(group: self, manager: manager)
                .eraseToAnyView()
        }
    }

    private var unfurledNavigationLink: AnyView {
        var destination = UnfurledFlagGroupView(group: self, manager: manager).eraseToAnyView()

#if os(iOS)

        destination = destination
            .navigationBarTitle(Text(info.flagValueSourceName), displayMode: .inline)
            .eraseToAnyView()

#elseif compiler(>=5.3.1)

        destination = destination
            .navigationTitle(info.flagValueSourceName)
            .eraseToAnyView()

#endif

        return NavigationLink(destination: destination) {
            HStack {
                Text(info.flagValueSourceName)
                    .font(.headline)
            }
        }.eraseToAnyView()
    }

}

#endif
