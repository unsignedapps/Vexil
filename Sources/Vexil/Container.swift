//
//  Container.swift
//  Vexil
//
//  Created by Rob Amos on 28/5/20.
//

import Combine
import Foundation

public protocol FlagContainer {
    init()
}

internal extension FlagContainer {
    subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
}
