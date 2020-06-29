//
//  Vexilographer.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 14/6/20.
//

import SwiftUI
import Vexil

public struct Vexilographer<RootGroup>: View where RootGroup: FlagContainer {

    // MARK: - Properties

    @ObservedObject var manager: FlagValueManager<RootGroup>


    // MARK: - Initialisation

    public init (flagPole: FlagPole<RootGroup>, source: FlagValueSource) {
        self.manager = FlagValueManager(flagPole: flagPole, source: source)
    }


    // MARK: - Body

    public var body: some View {
        Form {
            ForEach(self.manager.allItems(), id: \.id) { item in
                item.unfurledView
            }
                .environmentObject(self.manager)
        }
    }
}
