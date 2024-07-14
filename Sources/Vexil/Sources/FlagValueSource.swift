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

/// A simple protocol that describes a source of `FlagValue`s
///
/// For more information and examples on creating custom `FlagValueSource`s please
/// see the full documentation.
///
public protocol FlagValueSource: AnyObject & Identifiable & Sendable where ID == String {

    associatedtype ChangeStream: AsyncSequence where ChangeStream.Element == FlagChange

    /// The name of the source. Used by flag editors like Vexillographer
    var name: String { get }

    /// Provide a way to fetch values. The ``BoxedFlagValue`` type is there to help with boxing and unboxing of flag values.
    func flagValue<Value>(key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing. The ``BoxedFlagValue`` type is there to
    /// help with boxing and unboxing of flag values.
    ///
    /// It is expected if the value passed in is `nil` then the flag value would be cleared.
    ///
    func setFlagValue(_ value: (some FlagValue)?, key: String) throws

    /// Return an `AsyncSequence` that emits ``FlagChange`` values any time flag values have changed.
    /// If your implementation does not support real-time flag value monitoring you can return an ``EmptyFlagChangeStream``.
    var changes: ChangeStream { get }

}

public extension FlagValueSource {

    var id: String {
        name
    }

}
