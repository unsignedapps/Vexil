//
//  OptionalFlagControl.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 26/9/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

protocol OptionalFlagValue {
    associatedtype WrappedFlagValue: FlagValue

    var wrapped: WrappedFlagValue? { get set }

    init(_ wrapped: WrappedFlagValue?)
}

extension Optional: OptionalFlagValue where Wrapped: FlagValue {
    typealias WrappedFlagValue = Wrapped

    var wrapped: Wrapped? {
        get {
            self
        }
        set {
            self = newValue
        }
    }

    init(_ wrapped: Wrapped?) {
        self = wrapped
    }
}

#endif
