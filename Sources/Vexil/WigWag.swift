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

/// Wigwags are a type of signalling using flags, also known as aerial telegraphy.
///
/// A Wigwag in Vexil supports observing flag values for changes via an AsyncSequence. On Apple platforms
/// it also natively supports publishing via Combine.
///
/// For more information on Wigwags see https://en.wikipedia.org/wiki/Wigwag_(flag_signals)
///
public struct WigWag<Value> where Value: FlagValue {

    // MARK: - Properties

    /// The key path to this flag
    public let keyPath: FlagKeyPath

    /// The string-based key for this flag.
    public var key: String {
        keyPath.key
    }

    /// An optional display name to give the flag. Only visible in flag editors like Vexillographer.
    /// Default is to calculate one based on the property name.
    public let name: String?

    /// A description of this flag. Only visible in flag editors like Vexillographer.
    /// If this is nil the flag will be hidden.
    public let description: String?


    // MARK: - Initialisation

    /// Creates a Wigwag with the provided configuration.
    public init(keyPath: FlagKeyPath, name: String?, description: String?) {
        self.keyPath = keyPath
        self.name = name
        self.description = description
    }

}
