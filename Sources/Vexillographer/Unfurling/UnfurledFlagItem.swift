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

protocol UnfurledFlagItem {
    var id: UUID { get }
    var info: UnfurledFlagInfo { get }
    var hasChildren: Bool { get }
    var unfurledView: AnyView { get }
}

#endif
