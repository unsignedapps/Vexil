//
//  UnfurledFlagItem.swift
//  Vexil
//
//  Created by Rob Amos on 16/6/20.
//

import Foundation
import SwiftUI
import Vexil

protocol UnfurledFlagItem {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var hasChildren: Bool { get }
    var unfurledView: AnyView { get }
}
