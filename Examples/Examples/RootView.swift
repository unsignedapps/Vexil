//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Vexil
import Vexillographer

struct RootView: View {

    var body: some View {
        NavigationView {
            List {
                FlagControl(Dependencies.current.flags.$developerMenuEnabled) { configuration in
                    Section {
                        FlagToggle(configuration: configuration)
                    }
                    if configuration.value {
                        NavigationLink("Developer Menu") {
                            Vexillographer()
                        }
                    }
                }
            }
        }
        .flagPole(
            Dependencies.current.flags,
            editableSource: Dependencies.current.flags._sources.first
        )
        .flagControlStyle(.doubleAndBoolean)

    }

}

#Preview {
    RootView()
}
