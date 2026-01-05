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

public struct FlagKeyPath: Hashable, Sendable {

    public enum Key: Sendable {
        case root
        case automatic(String)
        case kebabcase(String)
        case snakecase(String)
        case customKey(String)
        case customKeyPath(String)
    }

    // MARK: - Properties

    let keyPath: [Key]

    public let key: String
    public let separator: String
    public let strategy: VexilConfiguration.CodingKeyStrategy

    // MARK: - Initialisation

    /// Memberwise initialiser
    init(
        _ keyPath: [Key],
        separator: String = ".",
        strategy: VexilConfiguration.CodingKeyStrategy = .default,
        key: String
    ) {
        self.keyPath = keyPath
        self.separator = separator
        self.strategy = strategy
        self.key = key
    }

    public init(
        _ keyPath: [Key],
        separator: String = ".",
        strategy: VexilConfiguration.CodingKeyStrategy = .default
    ) {
        self.keyPath = keyPath
        self.separator = separator
        self.strategy = strategy

        self.key = {
            var toReturn = [String]()
            for path in keyPath {
                switch path.stringKeyMode(strategy: strategy) {
                case let .append(key):          toReturn.append(key)
                case let .replace(key):         return key
                case .root:                     break
                }
            }
            return toReturn.joined(separator: separator)
        }()
    }

    public init(_ key: String, separator: String = ".", strategy: VexilConfiguration.CodingKeyStrategy = .default) {
        self.init([ .customKeyPath(key) ], separator: separator, strategy: strategy)
    }

    // MARK: - Common

    public func append(_ key: Key) -> FlagKeyPath {
        FlagKeyPath(
            keyPath + [ key ],
            separator: separator,
            strategy: strategy,
            key: {
                switch key.stringKeyMode(strategy: strategy) {
                case let .append(string) where self.key.isEmpty:
                    string
                case let .append(string):
                    self.key + separator + string
                case let .replace(string):
                    string
                case .root:
                    self.key     // mostly a noop
                }
            }()
        )
    }

    static func root(separator: String, strategy: VexilConfiguration.CodingKeyStrategy) -> FlagKeyPath {
        FlagKeyPath(
            [ .root ],
            separator: separator,
            strategy: strategy
        )
    }

    // MARK: - Hashable

    // Equality for us is based on the output key, not how it was created. Otherwise
    // keys coming back from external sources will never match an internally created one.

    public static func == (lhs: FlagKeyPath, rhs: FlagKeyPath) -> Bool {
        lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

}


private extension FlagKeyPath.Key {
    enum Mode {
        case append(String)
        case replace(String)
        case root
    }

    func stringKeyMode(strategy: VexilConfiguration.CodingKeyStrategy) -> Mode {
        switch (self, strategy) {
        case let (.automatic(key), .default), let (.automatic(key), .kebabcase), let (.kebabcase(key), _), let (.customKey(key), _):
            .append(key)
        case let (.automatic(key), .snakecase), let (.snakecase(key), _):
            .append(key.replacingOccurrences(of: "-", with: "_"))
        case let (.customKeyPath(key), _):
            .replace(key)
        case (.root, _):
            .root
        }
    }
}
