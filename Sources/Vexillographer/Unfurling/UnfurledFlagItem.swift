//
//  UnfurledFlagItem.swift
//  Vexil
//
//  Created by Rob Amos on 16/6/20.
//

#if os(iOS) || os(macOS)

import Foundation
import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol UnfurledFlagItem {
    var id: UUID { get }
    var info: UnfurledFlagInfo { get }
    var hasChildren: Bool { get }
    var children: [UnfurledFlagItem]? { get }
    var unfurledView: AnyView { get }
    var isEditable: Bool { get }
}

#endif
