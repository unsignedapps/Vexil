//
//  FlagView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 16/6/20.
//

import SwiftUI
import Vexil

struct UnfurledFlagView<Value, RootGroup>: View where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let flag: UnfurledFlag<Value, RootGroup>

    @ObservedObject var manager: FlagValueManager<RootGroup>

    @State private var showDetail = false


    // MARK: - Initialisation

    init (flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.flag = flag
        self.manager = manager
    }


    // MARK: - View Body

    var body: some View {
        ZStack {
            NavigationLink(destination: FlagDetailView(flag: self.flag, manager: self.manager), isActive: self.$showDetail) {
                EmptyView()
            }
            HStack {
                self.flagControl
                Button (
                    action: { self.showDetail = true },
                    label: { Image(systemName: "info.circle") }
                )
            }
        }
    }

    var flagControl: some View {
        if let flag = self.flag as? UnfurledFlag<Bool, RootGroup> {
            return BooleanFlagControl(label: flag.name, flagValue: Binding(flag: flag, manager: self.manager))
                .eraseToAnyView()
        }
        return EmptyView().eraseToAnyView()
    }
}
