//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Vexil

// Binding to a flag value could be a property wrapper but maybe best
// not to blur the lines
public struct FlagControlConfiguration<Value: FlagValue> {

    private let seed: Int
    public let name: String
    public let description: String?
    public let keyPath: FlagKeyPath
    public let isEditable: Bool
    public let hasValue: Bool
    public let defaultValue: Value
    @Binding
    public var value: Value
    private let _resetValue: () -> Void

    init(
        seed: Int,
        name: String,
        description: String? = nil,
        keyPath: FlagKeyPath,
        isEditable: Bool,
        hasValue: Bool,
        defaultValue: Value,
        value: Binding<Value>,
        resetValue: @escaping () -> Void
    ) {
        self.seed = seed
        self.name = name
        self.description = description
        self.keyPath = keyPath
        self.isEditable = isEditable
        self.hasValue = hasValue
        self.defaultValue = defaultValue
        _value = value
        self._resetValue = resetValue
    }

    public var key: String {
        keyPath.key
    }

    public func resetValue() {
        _resetValue()
    }

}
