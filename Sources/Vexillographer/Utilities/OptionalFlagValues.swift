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
