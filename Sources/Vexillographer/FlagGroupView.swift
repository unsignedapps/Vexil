//
//  FlagGroupView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 16/6/20.
//

// swiftlint:disable multiple_closures_with_trailing_closure

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
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
            .navigationBarTitle(Text(self.group.info.name), displayMode: .inline)
    }

    #elseif os(macOS)

    var body: some View {
        self.content
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }

    #else

    var body: some View {
        self.content
    }

    #endif

    var content: some View {
        Form {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description").font(.headline)
                Text(self.group.info.description)
            }
                .contextMenu {
                    Button(action: { self.group.info.description.copyToPasteboard() }) {
                        Text("Copy description to clipboard")
                    }
                }
            Section(header: Text("Flags")) {
                ForEach(self.group.allItems(), id: \.id) { item in
                    item.unfurledView
                }
            }
        }
    }
}

#endif
