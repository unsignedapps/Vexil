//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
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
/// The FlagWigwag in Vexil supports observing flag values for changes via an AsyncSequence.
/// On Apple platforms it also natively supports publishing via Combine.
///
/// For more information on Wigwags see https://en.wikipedia.org/wiki/Wigwag_(flag_signals)
///
public struct FlagWigwag<Output>: Sendable where Output: FlagValue {

    // MARK: - Properties

    /// The key path to this flag
    public let keyPath: FlagKeyPath

    /// The string-based key for this flag.
    public var key: String {
        keyPath.key
    }

    /// The default value for this flag
    public let defaultValue: Output

    /// The current resolved value of this flag
    public var value: Output {
        lookup.value(for: keyPath) ?? defaultValue
    }

    /// A human readable name for the flag. Only visible in flag editors like Vexillographer.
    public let name: String

    /// A description of this flag. Only visible in flag editors like Vexillographer.
    /// If this is nil the flag or flag group will be hidden.
    public let description: String?

    /// Options affecting the display of this flag or flag group
    public let displayOption: FlagDisplayOption

    /// How we can lookup flag value changes
    let lookup: any FlagLookup


    // MARK: - Initialisation

    /// Creates a Wigwag with the provided configuration.
    public init(
        keyPath: FlagKeyPath,
        name: String,
        defaultValue: Output,
        description: String?,
        displayOption: FlagDisplayOption,
        lookup: any FlagLookup
    ) {
        self.keyPath = keyPath
        self.name = name
        self.defaultValue = defaultValue
        self.description = description
        self.displayOption = displayOption
        self.lookup = lookup
    }

}


// MARK: - Async Sequence Support

extension FlagWigwag: AsyncSequence {

    public typealias Element = Output

    public typealias Sequence = AsyncChain2Sequence<AsyncSyncSequence<[Output]>, AsyncMapSequence<FilteredFlagChangeStream, Output>>

    public var changes: FilteredFlagChangeStream {
        FilteredFlagChangeStream(filter: .some([ keyPath ]), base: lookup.changes)
    }

    private func getOutput() -> Output {
        lookup.value(for: keyPath) ?? defaultValue
    }

    private func makeAsyncSequence() -> Sequence {
        chain(
            [ getOutput() ].async,
            changes.map { _ in getOutput() }
        )
    }

    public func makeAsyncIterator() -> Sequence.AsyncIterator {
        makeAsyncSequence()
            .makeAsyncIterator()
    }

}


// MARK: - Publisher Support

#if canImport(Combine)

extension FlagWigwag: Publisher {

    public typealias Output = Output
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        FlagPublisher(makeAsyncSequence())
            .receive(subscriber: subscriber)
    }

    /// A `Publisher` that provides real-time updates if any flag value changes.
    ///
    /// This method has been deprecated — you can access the publisher directly on the projected value
    /// eg if you've accessed this method as `path.$someFlag.publisher`, just use `path.$someFlag`
    @available(*, deprecated, message: "The `.publisher` method is no longer necessary, $someFlag will emit values directly.")
    public var publisher: Self {
        self
    }

}

#endif
