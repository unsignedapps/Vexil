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

#if !os(Linux)
import Combine
#endif

extension FlagValueDictionary: FlagValueSource {

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        guard let value = storage[key] else {
            return nil
        }
        return Value(boxedFlagValue: value)
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        if let value = value {
            storage.updateValue(value.boxedFlagValue, forKey: key)
        } else {
            storage.removeValue(forKey: key)
        }

#if !os(Linux)
        valueDidChange.send([ key ])
#endif

    }

#if !os(Linux)

    public func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        valueDidChange
            .eraseToAnyPublisher()
    }

#endif
}
