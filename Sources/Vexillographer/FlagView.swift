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

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct UnfurledFlagView<Value, RootGroup>: View where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let flag: UnfurledFlag<Value, RootGroup>

    @ObservedObject
    var manager: FlagValueManager<RootGroup>

    @State
    private var showDetail = false

    @State
    private var showPicker = false


    // MARK: - Initialisation

    init(flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.flag = flag
        self.manager = manager
    }


    // MARK: - View Body

    var body: some View {
        self.content
            .contextMenu {
                Button("Show Details") { self.showDetail = true }
            }
            .sheet(
                isPresented: self.$showDetail,
                content: {
                    self.detailView
                }
            )
    }

    var content: some View {

        if let flag = self.flag as? BooleanEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail)

        } else if let flag = self.flag as? OptionalBooleanEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail)

        } else if let flag = self.flag as? CaseIterableEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail, showPicker: self.$showPicker)

        } else if let flag = self.flag as? OptionalCaseIterableEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail, showPicker: self.$showPicker)

        } else if let flag = self.flag as? StringEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail)

        } else if let flag = self.flag as? OptionalStringEditableFlag {
            return flag.control(label: self.flag.info.name, manager: self.manager, showDetail: self.$showDetail)
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
        VStack {
            FlagDetailView(flag: self.flag, manager: self.manager)
            HStack {
                Spacer()
                self.detailDoneButton
            }
        }
        .padding()
    }

#endif

    var detailDoneButton: some View {
        Button("Close") {
            self.showDetail = false
        }
    }

}

#endif
