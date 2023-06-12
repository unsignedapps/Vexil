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

    // MARK: - Properties

    public let key: String
    public let separator: String


    // MARK: - Initialisation

    public init(_ keyPath: String, separator: String = ".") {
        self.key = keyPath
        self.separator = separator
    }


    // MARK: - Creating

    public func append(_ key: String) -> FlagKeyPath {
        FlagKeyPath(
            key + separator + key,
            separator: separator
        )
    }


    // MARK: - Common

    static func root(separator: String) -> FlagKeyPath {
        FlagKeyPath("", separator: separator)
    }

}
