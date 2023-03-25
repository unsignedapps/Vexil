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

extension FlagValueDictionary: Collection {

    public typealias Index = DictionaryType.Index
    public typealias Element = DictionaryType.Element

    public var startIndex: Index { return storage.startIndex }
    public var endIndex: Index { return storage.endIndex }

    public subscript(index: Index) -> Iterator.Element {
        return storage[index]
    }

    public subscript(key: Key) -> Value? {
        get { return storage[key] }
        set {
            if let value = newValue {
                storage.updateValue(value, forKey: key)
            } else {
                storage.removeValue(forKey: key)
            }
#if !os(Linux)
            valueDidChange.send([ key ])
#endif
        }
    }

    public func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    public var keys: DictionaryType.Keys {
        return storage.keys
    }

}
