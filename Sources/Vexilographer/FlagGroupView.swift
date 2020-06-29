//
//  FlagGroupView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 16/6/20.
//

import SwiftUI
import Vexil

struct UnfurledFlagGroupView<Group, Root>: View where Group: FlagContainer, Root: FlagContainer {

    // MARK: - Properties

    let group: UnfurledFlagGroup<Group, Root>
    @ObservedObject var manager: FlagValueManager<Root>


    // MARK: - Initialisation

    init (group: UnfurledFlagGroup<Group, Root>, manager: FlagValueManager<Root>) {
        self.group = group
        self.manager = manager
    }


    // MARK: - View Body

    #if os(iOS)

    var body: some View {
        self.content
            .navigationBarTitle(Text(self.group.name), displayMode: .inline)
    }

    #else

    var body: some View {
        self.content
    }

    #endif

    var content: some View {
        Form {
            Section {
                Text(self.group.description)
            }
            Section {
                ForEach(self.group.allItems(), id: \.id) { item in
                    item.unfurledView
                }
            }
        }
    }
}
