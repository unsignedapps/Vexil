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

import SwiftSyntax

extension AttributeSyntax.Arguments {

    subscript(label label: String) -> LabeledExprSyntax? {
        guard case let .argumentList(list) = self else {
            return nil
        }
        return list.first(where: { $0.label?.text == label })
    }

}
