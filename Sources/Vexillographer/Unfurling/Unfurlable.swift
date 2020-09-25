//
//  Unfurlable.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 15/6/20.
//

#if os(iOS) || os(macOS)

import Foundation
import Vexil

/// Describes a type that can "unfurl" itself.
///
/// Basically this is used to provide the Flag and FlagGroups with a way to create a type-erased `UnfurledFlagItem`
/// that describes themelves.
///
protocol Unfurlable {
    func unfurl<RootGroup> (label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer
}

extension Flag: Unfurlable where Value: FlagValue {

    /// Creates an `UnfurledFlag` from the receiver and returns it as a type-erased `UnfurledFlagItem`
    ///
    func unfurl<RootGroup> (label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer {
        guard self.info.shouldDisplay == true else { return nil }
        let unfurled = UnfurledFlag(name: self.info.name ?? label.localizedDisplayName, flag: self, manager: manager)
        return unfurled.isEditable ? unfurled : nil
    }
}

extension FlagGroup: Unfurlable {

    /// Creates an `UnfurledFlagGroup` from the receiver and returns it as a type-erased `UnfurledFlagItem`
    ///
    func unfurl<RootGroup>(label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem? where RootGroup: FlagContainer {
        guard self.info.shouldDisplay == true else { return nil }
        let unfurled = UnfurledFlagGroup(name: self.info.name ?? label.localizedDisplayName, group: self, manager: manager)
        return unfurled.isEditable ? unfurled : nil
    }
}

#endif
