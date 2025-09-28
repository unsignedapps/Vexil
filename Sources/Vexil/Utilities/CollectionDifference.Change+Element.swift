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

extension CollectionDifference.Change {

    var element: ChangeElement {
        switch self {
        case .insert(offset: _, element: let element, associatedWith: _):           element
        case .remove(offset: _, element: let element, associatedWith: _):           element
        }
    }

}
