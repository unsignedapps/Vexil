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

import AsyncAlgorithms

public enum FlagChange: Sendable, Equatable {

    /// All flags _may_ have changed. This change type often occurs when flags could be changed
    /// outside the bounds of the app using Vexil and we are unable to tell if any flags have changed,
    /// such as when returning from the background.
    case all

    /// One or more flag values have changed, as specified by the flag keys.
    case some(Set<FlagKeyPath>)

}

// MARK: - Filtered Change Stream

public struct FilteredFlagChangeStream: AsyncSequence, Sendable {

    public typealias Element = FlagChange
    public typealias Failure = Never

    let sequence: AsyncFilterSequence<FlagChangeStream>

    init(filter: FlagChange, base: FlagChangeStream) {
        self.sequence = base.filter { change in

            // If either our filter or the changes suggest all flags have changed we just pass it through
            guard case let .some(filtered) = filter, case let .some(changed) = change else {
                return true
            }

            // Only let it through if the flags that changed are in our list
            return filtered.intersection(changed).isEmpty == false
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        var iterator: AsyncFilterSequence<FlagChangeStream>.AsyncIterator

        public mutating func next() async -> Element? {
            await iterator.next()
        }

#if swift(>=6)
        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        public mutating func next(
            isolation actor: isolated (any Actor)?
        ) async -> FlagChange? {
            await iterator.next(isolation: actor)
        }
#endif
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(iterator: sequence.makeAsyncIterator())
    }

}


// MARK: - Empty Change Streams

/// Represents a flag source or flag lookup that is static and whose values do not change.
public struct EmptyFlagChangeStream: AsyncSequence, Sendable {

    public typealias Element = FlagChange
    public typealias Failure = Never

    public init() {
        // Intentionally left blank
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator()
    }

    public struct AsyncIterator: AsyncIteratorProtocol {

        public typealias Element = FlagChange

        public func next() async -> FlagChange? {
            nil
        }

#if swift(>=6)
        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        public func next(
            isolation actor: isolated (any Actor)?
        ) async -> FlagChange? {
            nil
        }
#endif
    }

}

extension FlagChange: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .all:              "FlagChange.all"
        case let .some(keys):   "FlagChange.some(\(keys.map(\.key).joined(separator: ", ")))"
        }
    }
}
