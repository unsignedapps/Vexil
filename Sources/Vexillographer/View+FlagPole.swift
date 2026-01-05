//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Vexil

public extension View {

    func flagPole(
        _ flagPole: FlagPole<some FlagContainer>,
        editableSource: (any FlagValueSource)? = nil
    ) -> some View {
        modifier(FlagPoleModifier(flagPole: flagPole, editableSource: editableSource))
    }

}

private struct FlagPoleModifier<RootGroup: FlagContainer>: ViewModifier {
    var flagPole: FlagPole<RootGroup>
    var editableSource: (any FlagValueSource)?

    func body(content: Content) -> some View {
        // TODO: Can cache this.
        let visitor = FlagPoleVisitor(lookup: flagPole)
        flagPole.walk(visitor: visitor)
        return content
            .transformEnvironment(\.flagPoleContext) {
                $0.items = visitor.items
                $0.keyPathByFlagKeyPath = visitor.keyPathByFlagKeyPath
                $0.editableSource = editableSource
                $0.streamManager = flagPole.manager
            }
    }
}
