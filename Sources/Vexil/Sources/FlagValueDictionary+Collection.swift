//
//  FlagValueDictionary+Collection.swift
//  Vexil
//
//  Created by Rob Amos on 19/8/20.
//

extension FlagValueDictionary: Collection {

    public typealias Index = DictionaryType.Index
    public typealias Element = DictionaryType.Element

    public var startIndex: Index { return self.storage.startIndex }
    public var endIndex: Index { return self.storage.endIndex }

    public subscript(index: Index) -> Iterator.Element {
        return self.storage[index]
    }

    public subscript(key: Key) -> Value? {
        get { return self.storage[key] }
        set {
            if let value = newValue {
                self.storage.updateValue(value, forKey: key)
            } else {
                self.storage.removeValue(forKey: key)
            }
        }
    }

    public func index(after i: Index) -> Index {
        return self.storage.index(after: i)
    }

    public var keys: DictionaryType.Keys {
        return self.storage.keys
    }

}
