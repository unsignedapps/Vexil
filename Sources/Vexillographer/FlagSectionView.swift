//
//  FlagSectionView.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 4/10/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagSectionView<Group, Root>: View where Group: FlagContainer, Root: FlagContainer {

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
            .navigationBarTitle(Text(self.group.info.name), displayMode: .inline)
    }

    #else

    var body: some View {
        self.content
    }

    #endif

    var content: some View {
        Section (
            header: Text(self.group.info.name),
            footer: Text(self.group.info.description),
            content: {
                ForEach(self.group.allItems(), id: \.id) { item in
                    item.unfurledView
                }
            }
        )
    }
}

#endif
