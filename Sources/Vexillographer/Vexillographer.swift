//
//  Vexillographer.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 14/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
public struct Vexillographer<RootGroup>: View where RootGroup: FlagContainer {

    // MARK: - Properties

    @ObservedObject var manager: FlagValueManager<RootGroup>


    // MARK: - Initialisation

    public init (flagPole: FlagPole<RootGroup>, source: FlagValueSource) {
        self.manager = FlagValueManager(flagPole: flagPole, source: source)
    }


    // MARK: - Body

    #if os(macOS) && compiler(>=5.3.1)

    public var body: some View {
        List(self.manager.allItems(), id: \.id, children: \.childLinks) { item in
            item.unfurledView
        }
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: NSApp.toggleKeyWindowSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
    }

    #else

    public var body: some View {
        ForEach(self.manager.allItems(), id: \.id) { item in
            item.unfurledView
        }
            .environmentObject(self.manager)
    }

    #endif
}

#endif
