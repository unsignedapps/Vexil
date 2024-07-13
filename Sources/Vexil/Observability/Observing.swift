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

import AsyncAlgorithms

public enum FlagChange: Sendable {

    /// All flags _may_ have changed. This change type often occurs when flags could be changed
    /// outside the bounds of the app using Vexil and we are unable to tell if any flags have changed,
    /// such as when returning from the background.
    case all

    /// One or more flag values have changed, as specified by the flag keys.
    case some(Set<FlagKeyPath>)

}

public typealias FlagChangeStream = AsyncStream<FlagChange>


// MARK: - Filtered Change Stream

public struct FilteredFlagChangeStream: AsyncSequence, Sendable {

    public typealias Element = FlagChange

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

    public func makeAsyncIterator() -> AsyncFilterSequence<FlagChangeStream>.AsyncIterator {
        sequence.makeAsyncIterator()
    }

}


// MARK: - Empty Change Streams

/// Represents a flag source or flag lookup that is static and whose values do not change.
public struct EmptyFlagChangeStream: AsyncSequence, Sendable {

    public typealias Element = FlagChange

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator()
    }

    public struct AsyncIterator: AsyncIteratorProtocol {

        public typealias Element = FlagChange

        public func next() async throws -> FlagChange? {
            nil
        }

    }

}
