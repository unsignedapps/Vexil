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

#if os(iOS) || os(macOS) || os(visionOS)

import Foundation
import Vexil

/// Describes a type that can "unfurl" itself.
///
/// Basically this is used to provide the Flag and FlagGroups with a way to create a type-erased `UnfurledFlagItem`
/// that describes themelves.
///
@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol Unfurlable {
    func unfurl<RootGroup>(label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension Flag: Unfurlable where Value: FlagValue {

    /// Creates an `UnfurledFlag` from the receiver and returns it as a type-erased `UnfurledFlagItem`
    ///
    func unfurl<RootGroup>(label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer {
        guard info.shouldDisplay == true else {
            return nil
        }
        let unfurled = UnfurledFlag(name: info.name ?? label.localizedDisplayName, flag: self, manager: manager)
        return unfurled.isEditable ? unfurled : nil
    }
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension FlagGroup: Unfurlable {

    /// Creates an `UnfurledFlagGroup` from the receiver and returns it as a type-erased `UnfurledFlagItem`
    ///
    func unfurl<RootGroup>(label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer {
        guard info.shouldDisplay == true else {
            return nil
        }
        let unfurled = UnfurledFlagGroup(name: info.name ?? label.localizedDisplayName, group: self, manager: manager)
        return unfurled.isEditable ? unfurled : nil
    }
}

#endif
