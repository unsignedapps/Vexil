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

/// A simple transformer that converts a FlagValue into a string for editing with a TextField
///
struct LosslessStringTransformer<Value>: BoxedFlagValueTransformer where Value: LosslessStringConvertible {
    typealias OriginalValue = Value
    typealias EditingValue = String

    static func toEditingValue(_ value: Value?) -> String {
        value!.description
    }

    static func toOriginalValue(_ value: String) -> Value? {
        Value(value)
    }
}

#endif
