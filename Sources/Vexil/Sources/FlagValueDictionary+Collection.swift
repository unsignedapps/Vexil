//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
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

    public var startIndex: Index {
        storage.withLock { storage in
            storage.startIndex
        }
    }

    public var endIndex: Index {
        storage.withLock { storage in
            storage.endIndex
        }
    }

    public subscript(index: Index) -> Iterator.Element {
        storage.withLock { storage in
            storage[index]
        }
    }

    public subscript(key: Key) -> Value? {
        get {
            storage.withLock { storage in
                storage[key]
            }
        }
        set {
            _ = storage.withLock { storage in
                if let value = newValue {
                    storage.updateValue(value, forKey: key)
                } else {
                    storage.removeValue(forKey: key)
                }
            }
            stream.send(.some([ FlagKeyPath(key) ]))
        }
    }

    public func index(after i: Index) -> Index {
        storage.withLock { storage in
            storage.index(after: i)
        }
    }

    public var keys: DictionaryType.Keys {
        storage.withLock { storage in
            storage.keys
        }
    }

}
