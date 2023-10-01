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

public struct FlagKeyPath: Hashable, Sendable {

    public enum Key: Hashable, Sendable {
        case root
        case automatic(String)
        case kebabcase(String)
        case snakecase(String)
        case customKey(String)
        case customKeyPath(String)
    }

    // MARK: - Properties

    let keyPath: [Key]
    public let separator: String
    public let strategy: VexilConfiguration.CodingKeyStrategy

    // MARK: - Initialisation

    public init(
        _ keyPath: [Key],
        separator: String = ".",
        strategy: VexilConfiguration.CodingKeyStrategy = .default
    ) {
        self.keyPath = keyPath
        self.separator = separator
        self.strategy = strategy
    }

    public init(_ key: String, separator: String = ".", strategy: VexilConfiguration.CodingKeyStrategy = .default) {
        self.init([ .customKeyPath(key) ], separator: separator, strategy: strategy)
    }

    // MARK: - Common

    public func append(_ key: Key) -> FlagKeyPath {
        FlagKeyPath(
            keyPath + [ key ],
            separator: separator,
            strategy: strategy
        )
    }

    public var key: String {
        var toReturn = [String]()
        for path in keyPath {
            switch (path, strategy) {
            case let (.automatic(key), .default), let (.automatic(key), .kebabcase), let (.kebabcase(key), _), let (.customKey(key), _):
                toReturn.append(key)
            case let (.automatic(key), .snakecase), let (.snakecase(key), _):
                toReturn.append(key.replacingOccurrences(of: "-", with: "_"))
            case let (.customKeyPath(key), _):
                return key
            case (.root, _):
                break
            }
        }
        return toReturn.joined(separator: separator)
    }

    static func root(separator: String, strategy: VexilConfiguration.CodingKeyStrategy) -> FlagKeyPath {
        FlagKeyPath(
            [ .root ],
            separator: separator,
            strategy: strategy
        )
    }

}
