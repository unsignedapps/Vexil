//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
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

    // MARK: - Initialisation

    init(flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.flag = flag
        self.manager = manager
    }


    // MARK: - View Body

    var body: some View {
        content
            .contextMenu {
                Button("Show Details") { showDetail = true }
            }
            .sheet(
                isPresented: $showDetail,
                content: {
                    detailView
                }
            )
    }

    var content: some View {

        if let flag = flag as? BooleanEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)

        } else if let flag = flag as? OptionalBooleanEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)

        } else if let flag = flag as? CaseIterableEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)

        } else if let flag = flag as? OptionalCaseIterableEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)

        } else if let flag = flag as? StringEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)

        } else if let flag = flag as? OptionalStringEditableFlag {
            return flag.control(label: self.flag.info.flagValueSourceName, manager: manager, showDetail: $showDetail)
        }

        return EmptyView().eraseToAnyView()
    }

#if os(iOS)

    var detailView: some View {
        NavigationView {
            FlagDetailView(flag: flag, manager: manager)
                .navigationBarItems(trailing: detailDoneButton)
        }
    }

#elseif os(macOS)

    var detailView: some View {
        VStack {
            FlagDetailView(flag: flag, manager: manager)
            HStack {
                Spacer()
                detailDoneButton
            }
        }
        .padding()
    }

#endif

    var detailDoneButton: some View {
        Button("Close") {
            showDetail = false
        }
    }

}

#endif
