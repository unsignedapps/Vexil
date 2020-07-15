//
//  FlagView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 16/6/20.
//

#if os(iOS) || os(macOS)

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
        self.content
            .sheet (
                isPresented: self.$showDetail,
                content: {
                    self.detailView
                }
            )
    }

    var content: some View {

        if let flag = self.flag as? BooleanEditableFlag {
            return flag.control (
                label: self.flag.info.name,
                manager: self.manager,
                showDetail: self.$showDetail
            )
                .eraseToAnyView()

        } else if let flag = self.flag as? CaseIterableEditableFlag {
            return flag.control (
                label: self.flag.info.name,
                manager: self.manager,
                showDetail: self.$showDetail
            )

        } else if let flag = self.flag as? StringEditableFlag {
            return flag.control (
                label: self.flag.info.name,
                manager: self.manager,
                showDetail: self.$showDetail
            )
                .eraseToAnyView()
        }

        return EmptyView().eraseToAnyView()
    }

    #if os(iOS)

    var detailView: some View {
        NavigationView {
            FlagDetailView(flag: self.flag, manager: self.manager)
                .navigationBarItems(trailing: self.detailDoneButton)
        }
    }

    #elseif os(macOS)

    var detailView: some View {
        NavigationView {
            FlagDetailView(flag: self.flag, manager: self.manager)
        }
    }

    #endif

    var detailDoneButton: some View {
        Button (
            action: { self.showDetail = false },
            label: { Text("Close").font(.headline) }
        )
    }

}

#endif
