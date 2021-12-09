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
open class FlagValueDictionary: Identifiable, ExpressibleByDictionaryLiteral, Codable {

    // MARK: - Properties

    /// A Unique Identifier for this FlagValueDictionary
    public let id: UUID

    /// Our internal dictionary type
    public typealias DictionaryType = [String: BoxedFlagValue]

    internal var storage: DictionaryType

    #if !os(Linux)
    private(set) internal var valueDidChange = PassthroughSubject<Set<String>, Never>()
    #endif


    // MARK: - Initialisation

    /// Private (but for @testable) memeberwise initialiser
    init (id: UUID, storage: DictionaryType) {
        self.id = id
        self.storage = storage
    }

    /// Initialises a `FlagValueDictionary` with the specified dictionary
    ///
    public convenience init (_ dictionary: DictionaryType = [:]) {
        self.init(
            id: UUID(),
            storage: dictionary
        )
    }

    /// Initialises a `FlagValueDictionary` using a dictionary literal
    ///
    public required init(dictionaryLiteral elements: (String, BoxedFlagValue)...) {
        self.id = UUID()
        self.storage = elements.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.1, forKey: pair.0)
        }
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id
        case storage
    }

}

// MARK: - Equatable Support

extension FlagValueDictionary: Equatable {
    public static func == (lhs: FlagValueDictionary, rhs: FlagValueDictionary) -> Bool {
        return lhs.id == rhs.id && lhs.storage == rhs.storage
    }
}
