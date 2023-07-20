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

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

#if os(macOS) && compiler(>=5.3.1)

/// A SwiftUI View that allows you to easily edit the flag
/// structure in a provided FlagValueSource.
@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
public struct Vexillographer<RootGroup>: View where RootGroup: FlagContainer {

    // MARK: - Properties

    @ObservedObject
    var manager: FlagValueManager<RootGroup>

    // MARK: - Initialisation

    /// Initialises a new `Vexillographer` instance with the provided FlagPole and source
    ///
    /// - Parameters;
    ///   - flagPole:           A `FlagPole` instance manages the flag and source hierarchy we want to display
    ///   - source:             An optional `FlagValueSource` for editing the flag values in. If `nil` the flag values are displayed read-only
    ///
    public init(flagPole: FlagPole<RootGroup>, source: FlagValueSource?) {
        self._manager = ObservedObject(wrappedValue: FlagValueManager(flagPole: flagPole, source: source))
    }

    // MARK: - Body

    public var body: some View {
        List(self.manager.allItems(), id: \.id, children: \.childLinks) { item in
            UnfurledFlagItemView(item: item)
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
}

#else

/// A SwiftUI View that allows you to easily edit the flag
/// structure in a provided FlagValueSource.
@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
public struct Vexillographer<RootGroup>: View where RootGroup: FlagContainer {

    // MARK: - Properties

    @State
    var manager: FlagValueManager<RootGroup>

    // MARK: - Initialisation

    /// Initialises a new `Vexillographer` instance with the provided FlagPole and source
    ///
    /// - Parameters;
    ///   - flagPole:           A `FlagPole` instance manages the flag and source hierarchy we want to display
    ///   - source:             An optional `FlagValueSource` for editing the flag values in. If `nil` the flag values are displayed read-only
    ///
    public init(flagPole: FlagPole<RootGroup>, source: FlagValueSource?) {
        self._manager = State(wrappedValue: FlagValueManager(flagPole: flagPole, source: source))
    }

    public var body: some View {
        ForEach(self.manager.allItems(), id: \.id) { item in
            UnfurledFlagItemView(item: item)
        }
        .environmentObject(self.manager)
    }
}

#endif

#endif
