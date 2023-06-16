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

import VexilMacros

@attached(accessor)
public macro FlagGroup(
    name: String? = nil,
    keyStrategy: VexilConfiguration.GroupKeyStrategy = .default,
    description: String,
    display: FlagGroupDisplay = .navigation
) = #externalMacro(module: "VexilMacros", type: "FlagGroupMacro")


// MARK: - Group Display

/// How to display this group in Vexillographer
public enum FlagGroupDisplay {

    /// Hides this group.
    case hidden

    /// Displays this group using a `NavigationLink`. This is the default.
    ///
    /// In the navigated view the `name` is the cell's display name and the navigated view's
    /// title, and the `description` is displayed at the top of the navigated view.
    ///
    case navigation

    /// Displays this group using a `Section`
    ///
    /// The `name` of this FlagGroup is used as the Section's header, and the `description`
    /// as the Section's footer.
    ///
    case section

}
