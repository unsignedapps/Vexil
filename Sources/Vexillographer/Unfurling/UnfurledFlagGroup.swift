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

struct UnfurledFlagGroup<Group, Root>: UnfurledFlagItem, Identifiable where Group: FlagContainer, Root: FlagContainer {

    // MARK: - Properties

    let info: UnfurledFlagInfo
    let group: FlagGroup<Group>
    let hasChildren = true

    private let manager: FlagValueManager<Root>

    var id: UUID {
        return self.group.id
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
                return unfurlable.unfurl(label: label, manager: self.manager)
            }
    }

    var unfurledView: AnyView {
        return NavigationLink(destination: UnfurledFlagGroupView(group: self, manager: self.manager)) {
            HStack {
                Text(self.info.name)
                    .font(.headline)
            }
        }
            .eraseToAnyView()
    }
}

struct UnfurledFlagGroup_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

#endif
