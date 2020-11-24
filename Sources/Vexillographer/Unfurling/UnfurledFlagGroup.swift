//
//  UnfurledFlagGroup.swift
//  Vexil
//
//  Created by Rob Amos on 16/6/20.
//

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
        return self.group.id
    }

    var isEditable: Bool {
        return self.allItems()
            .isEmpty == false
    }

    var isLink: Bool {
        return self.group.display == .navigation
    }

    var childLinks: [UnfurledFlagItem]? {
        let children = self.allItems().filter { $0.hasChildren == true && $0.isLink }
        return children.isEmpty == false ? children : nil
    }

    // MARK: - Initialisation

    init (name: String, group: FlagGroup<Group>, manager: FlagValueManager<Root>) {
        self.info = UnfurledFlagInfo(key: "", info: group.info, defaultName: name)
        self.group = group
        self.manager = manager
    }


    // MARK: - Unfurled Flag Item Conformance

    func allItems () -> [UnfurledFlagItem] {
        return Mirror(reflecting: self.group.wrappedValue)
            .children
            .compactMap { child -> UnfurledFlagItem? in
                guard let label = child.label, let unfurlable = child.value as? Unfurlable else { return nil }
                guard let unfurled = unfurlable.unfurl(label: label, manager: self.manager) else { return nil }
                return unfurled.isEditable ? unfurled : nil
            }
    }

    var unfurledView: AnyView {
        switch self.group.display {
        case .navigation:
            return self.unfurledNavigationLink

        case .section:
            return UnfurledFlagSectionView(group: self, manager: self.manager)
                .eraseToAnyView()
        }
    }

    private var unfurledNavigationLink: AnyView {
        var destination = UnfurledFlagGroupView(group: self, manager: self.manager).eraseToAnyView()

        #if os(iOS)

        destination = destination
            .navigationBarTitle(Text(self.info.name), displayMode: .inline)
            .eraseToAnyView()

        #else

        destination = destination
            .navigationTitle(self.info.name)
            .eraseToAnyView()

        #endif

        return NavigationLink(destination: destination) {
            HStack {
                Text(self.info.name)
                    .font(.headline)
            }
        }.eraseToAnyView()
    }

}

#endif
