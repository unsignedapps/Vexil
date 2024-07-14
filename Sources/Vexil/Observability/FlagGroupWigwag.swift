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

#if canImport(Combine)
import Combine
#endif

/// Wigwags are a type of signalling using flags, also known as aerial telegraphy.
///
/// The GroupWigwag in Vexil supports observing flag containers for changes via an AsyncSequence.
/// On Apple platforms it also natively supports publishing via Combine.
///
/// For more information on Wigwags see https://en.wikipedia.org/wiki/Wigwag_(flag_signals)
///
public struct FlagGroupWigwag<Output>: Sendable where Output: FlagContainer {

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
    /// If this is nil the flag or flag group will be hidden.
    public let description: String?

    /// Options affecting the display of this flag or flag group
    public let displayOption: FlagGroupDisplayOption?

    /// How we can lookup flag value changes
    let lookup: any FlagLookup


    // MARK: - Initialisation

    /// Creates a Wigwag with the provided configuration.
    public init(
        keyPath: FlagKeyPath,
        name: String?,
        description: String?,
        displayOption: FlagGroupDisplayOption?,
        lookup: any FlagLookup
    ) {
        self.keyPath = keyPath
        self.name = name
        self.description = description
        self.displayOption = displayOption
        self.lookup = lookup
    }

}


// MARK: - Async Sequence Support

extension FlagGroupWigwag: AsyncSequence {

    public typealias Element = Output

    public typealias Sequence = AsyncChain2Sequence<AsyncSyncSequence<[Output]>, AsyncMapSequence<FilteredFlagChangeStream, Output>>

    public var changeStream: FilteredFlagChangeStream {
        FilteredFlagChangeStream(filter: .some([ keyPath ]), base: lookup.changeStream)
    }

    private func getOutput() -> Output {
        Output(_flagKeyPath: keyPath, _flagLookup: lookup)
    }

    private func makeAsyncSequence() -> Sequence {
        chain(
            [ getOutput() ].async,
            changeStream.map { _ in getOutput() }
        )
    }

    public func makeAsyncIterator() -> Sequence.AsyncIterator {
        makeAsyncSequence()
            .makeAsyncIterator()
    }

}


// MARK: - Publisher Support

#if canImport(Combine)

extension FlagGroupWigwag: Publisher {

    public typealias Output = Output
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        FlagPublisher(makeAsyncSequence())
            .receive(subscriber: subscriber)
    }

}

#endif
