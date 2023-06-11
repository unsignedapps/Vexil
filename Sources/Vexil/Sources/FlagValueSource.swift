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

#if !os(Linux)
import Combine
#endif

import Foundation

/// A simple protocol that describes a source of `FlagValue`s
///
/// For more information and examples on creating custom `FlagValueSource`s please
/// see the full documentation.
///
public protocol FlagValueSource {

    /// The name of the source. Used by flag editors like Vexillographer
    var name: String { get }

    /// Provide a way to fetch values
    func flagValue<Value>(key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing
    ///
    /// It is expected if the value passed in is `nil` then the flag value would be cleared
    ///
    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue

#if !os(Linux)

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates.
    ///
    /// - Important: Use of this method is deprecated. Please implement `valuesDidChange(keys:)` instead
    ///              and emit an empty array if your source does not know which keys changed.
    ///
    var valuesDidChange: AnyPublisher<Void, Never>? { get }

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates.
    ///
    /// If your source does not know which keys changed please emit an empty array.
    ///
    func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>?

#endif
}

#if !os(Linux)

/// Make support for real-time flag updates optional by providing a default nil implementation
///
public extension FlagValueSource {
    var valuesDidChange: AnyPublisher<Void, Never>? {
        nil
    }

    func valuesDidChange(keys: Set<String>) -> AnyPublisher<Set<String>, Never>? {
        nil
    }
}

#endif
