//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
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
public final class FlagValueDictionary: Identifiable, ExpressibleByDictionaryLiteral, Codable, Sendable {

    // MARK: - Properties

    /// A Unique Identifier for this FlagValueDictionary
    public let id: String

    /// The name of our `FlagValueSource`
    public var flagValueSourceName: String {
        "\(String(describing: Self.self)): \(id)"
    }

    /// Our internal dictionary type
    public typealias DictionaryType = [String: BoxedFlagValue]

    let storage: Lock<DictionaryType>

    let stream: AsyncStream<String>
    let continuation: AsyncStream<String>.Continuation


    // MARK: - Initialisation

    /// Private (but for @testable) memeberwise initialiser
    init(id: String, storage: DictionaryType) {
        self.id = id
        self.storage = .init(initialState: storage)
        (self.stream, self.continuation) = AsyncStream.makeStream()
    }

    /// Initialises an empty `FlagValueDictionary`
    public init() {
        self.id = UUID().uuidString
        self.storage = .init(initialState: [:])
        (self.stream, self.continuation) = AsyncStream.makeStream()
    }

    /// Initialises a `FlagValueDictionary` with the specified dictionary
    public init(_ sequence: some Sequence<(key: String, value: BoxedFlagValue)>) {
        self.id = UUID().uuidString
        self.storage = .init(initialState: sequence.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.value, forKey: pair.key)
        })
        (self.stream, self.continuation) = AsyncStream.makeStream()
    }

    /// Initialises a `FlagValueDictionary` using a dictionary literal
    public init(dictionaryLiteral elements: (String, BoxedFlagValue)...) {
        self.id = UUID().uuidString
        self.storage = .init(initialState: elements.reduce(into: [:]) { dict, pair in
            dict.updateValue(pair.1, forKey: pair.0)
        })
        (self.stream, self.continuation) = AsyncStream.makeStream()
    }

    // MARK: - Dictionary Access

    /// Returns a copy of the current values in this source
    public var allValues: DictionaryType {
        storage.withLock { $0 }
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id
        case storage
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.storage = try .init(initialState: container.decode(DictionaryType.self, forKey: .storage))
        (self.stream, self.continuation) = AsyncStream.makeStream()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(storage.withLock { $0 }, forKey: .storage)
    }

}
