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

    /// A Unique Identifier for this FlagValueDictionary
    public let id = UUID()

    /// Our internal dictionary type
    public typealias DictionaryType = [String: Any]

    internal var storage: DictionaryType {
        didSet {
            #if !os(Linux)
            self.valueDidChange.send()
            #endif
        }
    }

    #if !os(Linux)
    private(set) internal var valueDidChange = PassthroughSubject<Void, Never>()
    #endif


    // MARK: - Initialisation

    /// Initialises a `FlagValueDictionary` with the specified dictionary
    ///
    public init (_ dictionary: DictionaryType = [:]) {
        self.storage = dictionary
    }

    /// Initialises a `FlagValueDictionary` using a dictionary literal
    ///
    public required init(dictionaryLiteral elements: (String, Any)...) {
        self.storage = elements.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.1, forKey: pair.0)
        }
    }

}
