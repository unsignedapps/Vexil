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
    public let id: String

    /// The name of our `FlagValueSource`
    public var name: String {
        "\(String(describing: Self.self)): \(id)"
    }

    /// Our internal dictionary type
    public typealias DictionaryType = [String: BoxedFlagValue]

    internal var storage: DictionaryType

    let stream = StreamManager.Stream()


    // MARK: - Initialisation

    /// Private (but for @testable) memeberwise initialiser
    init(id: String, storage: DictionaryType) {
        self.id = id
        self.storage = storage
    }

    /// Initialises an empty `FlagValueDictionary`
    public init() {
        self.id = UUID().uuidString
        self.storage = [:]
    }

    /// Initialises a `FlagValueDictionary` with the specified dictionary
    ///
    public required init(_ sequence: some Sequence<(key: String, value: BoxedFlagValue)>) {
        self.id = UUID().uuidString
        self.storage = sequence.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.value, forKey: pair.key)
        }
    }

    /// Initialises a `FlagValueDictionary` using a dictionary literal
    ///
    public required init(dictionaryLiteral elements: (String, BoxedFlagValue)...) {
        self.id = UUID().uuidString
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
        lhs.id == rhs.id && lhs.storage == rhs.storage
    }
}
