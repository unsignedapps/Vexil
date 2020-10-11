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
        Form {
            self.description
                .padding([.top, .bottom], 4)
            Section(header: Text("Flags")) {
                self.flags
            }
        }
            .navigationBarTitle(Text(self.group.info.name), displayMode: .inline)
    }

    #elseif os(macOS)

    var body: some View {
        VStack(alignment: .leading) {
            self.description
                .padding(.bottom, 8)
            Divider()
        }
            .padding()

        Form {
            Section {
                self.flags
            }
        }
            .padding([.leading, .trailing, .bottom], 30)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle(self.group.info.name)
    }

    #else

    var body: some View {
        Form {
            self.description
            Section {
                self.flags
            }
        }
    }

    #endif

    var description: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description").font(.headline)
            Text(self.group.info.description)
        }
            .contextMenu {
                Button(action: self.group.info.description.copyToPasteboard) {
                    if #available(iOS 14, watchOS 7, tvOS 14, *) {
                        Label("Copy", systemImage: "doc.on.doc")
                    } else {
                        Text("Copy")
                    }
                }
            }
    }

    var flags: some View {
        ForEach(self.group.allItems(), id: \.id) { item in
            item.unfurledView
        }
    }

}

#endif
