//
//  FlagValueDictionary.swift
//  Vexil
//
//  Created by Rob Amos on 15/8/20.
//

#if !os(Linux)
import Combine
#endif

import Foundation

/// A simple dictionary-backed FlagValueSource that can be useful for testing
/// and other purposes.
///
open class FlagValueDictionary: Identifiable, ExpressibleByDictionaryLiteral {

    // MARK: - Properties

    public let id = UUID()

    public typealias DictionaryType = [String: Any]

    internal var storage: DictionaryType {
        didSet {
            #if !os(Linux)
            self.valueDidChange.send()
            #endif
        }
    }

    #if !os(Linux)
    private var valueDidChange = PassthroughSubject<Void, Never>()
    #endif


    // MARK: - Initialisation

    /// Initialises a `FlagValueDictionary` with the specified dictionary
    ///
    public init (_ dictionary: DictionaryType = [:]) {
        self.storage = dictionary
    }

    public required init(dictionaryLiteral elements: (String, Any)...) {
        self.storage = elements.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.1, forKey: pair.0)
        }
    }

}


// MARK: - Flag Value Source

extension FlagValueDictionary: FlagValueSource {
    public var name: String {
        return "\(String(describing: Self.self)): \(self.id.uuidString)"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.storage[key] as? Value
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        if let value = value {
            self.storage.updateValue(value, forKey: key)
        } else {
            self.storage.removeValue(forKey: key)
        }
    }

    #if !os(Linux)

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates
    ///
    public var valuesDidChange: AnyPublisher<Void, Never>? {
        self.valueDidChange
            .eraseToAnyPublisher()
    }

    #endif
}


// MARK: - Collection

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

}
