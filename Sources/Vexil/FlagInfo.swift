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

/// A simple collection of information about a `Flag` or `FlagGroup`
///
/// This is mostly used by flag editors like Vexillographer.
///
public struct FlagInfo {

    // MARK: - Properties

    /// The name of the flag or flag group, if nil it is calculated from the containing property name
    public var name: String?

    /// A brief description of the flag or flag group's purpose
    public var description: String

    /// Whether or not the flag or flag group should be visible in Vexillographer
    public var shouldDisplay: Bool


    // MARK: - Initialisation

    /// Internal memberwise initialiser
    ///
    init(name: String?, description: String, shouldDisplay: Bool) {
        self.name = name
        self.description = description
        self.shouldDisplay = shouldDisplay
    }

    /// Allows a `FlagInfo` to be initialised directly when required
    ///
    /// - Parameters:
    ///   - description:        A brief description of the `Flag` or `FlagGroup`s purpose.
    ///
    public init(description: String) {
        self.init(name: nil, description: description, shouldDisplay: true)
    }
}


// MARK: - Hidden Flags

public extension FlagInfo {

    /// Hides the `Flag` or `FlagGroup` from flag editors like Vexillographer
    static let hidden = FlagInfo(name: nil, description: "", shouldDisplay: false)
}


// MARK: - String Literal Support

extension FlagInfo: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: nil, description: value, shouldDisplay: true)
    }
}
