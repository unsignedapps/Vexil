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

/// An internal storage type that the FlagPole can use to keep track of sources and change streams.
///
/// This works by subscribing everything through a central `channel`:
///
///     Source 1───┐   ┌───────────┐  ┌──► Subscriber 1
///                │   │           │  │
///     Source 2───┼──►│  Stream   ├──┼──► Subscriber 2
///                │   │           │  │
///     Source 3───┘   └───────────┘  └──► Subscriber 3
///
package struct StreamManager {

    // MARK: - Properties

    /// An array of `FlagValueSource`s that are used during flag value lookup.
    ///
    /// The order of this array is the order used when looking up flag values.
    ///
    package var sources: [any FlagValueSource]

    /// This channel acts as our central "Subject" (in Combine terms). The channel is
    /// listens to change streams coming from the various sources, and subscribers to this
    /// FlagPole listen to changes from the channel.
    var stream: Stream?

    /// All of the active tasks that are iterating over changes emitted by the sources and sending them to the change stream
    var tasks = [(String, Task<Void, Never>)]()

}

// MARK: - Stream Setup: Subject -> Sources

extension FlagPole {

    var stream: StreamManager.Stream {
        manager.withLock { manager in
            // Streaming already started
            if let stream = manager.stream {
                return stream
            }

            // Setup streaming
            let stream = StreamManager.Stream(keyPathMapper: _configuration.makeKeyPathMapper())
            manager.stream = stream
            subscribeChannel(oldSources: [], newSources: manager.sources, on: &manager, isInitialSetup: true)
            return stream
        }
    }

    func subscribeChannel(oldSources: [any FlagValueSource], newSources: [any FlagValueSource], on manager: inout StreamManager, isInitialSetup: Bool = false) {
        let difference = newSources.difference(from: oldSources, by: { $0.flagValueSourceID == $1.flagValueSourceID })
        var didChange = false

        // If a source has been removed, cancel any streams using it
        if difference.removals.isEmpty == false {
            didChange = true
            for removal in difference.removals {
                manager.tasks.removeAll { task in
                    if task.0 == removal.element.flagValueSourceID {
                        task.1.cancel()
                        return true
                    } else {
                        return false
                    }
                }
            }
        }

        // Setup streaming for all new sources
        if difference.insertions.isEmpty == false {
            didChange = true
            for insertion in difference.insertions {
                manager.tasks.append(
                    (insertion.element.flagValueSourceID, makeSubscribeTask(for: insertion.element))
                )
            }
        }

        // If we have changed then the values returned by any flag could be
        // different know, so we let everyone know.
        if isInitialSetup == false, didChange {
            manager.stream?.send(.all)
        }
    }

    private func makeSubscribeTask(for source: some FlagValueSource) -> Task<Void, Never> {
        .detached { [manager, _configuration] in
            do {
                for try await change in source.flagValueChanges(keyPathMapper: _configuration.makeKeyPathMapper()) {
                    manager.withLock {
                        $0.stream?.send(change)
                    }
                }

            } catch {
                // the source's change stream threw; treat it as
                // if it finished (by doing nothing about it)
            }
        }
    }

}

extension StreamManager {

    /// A  convenience wrapper to AsyncStream.
    ///
    /// As this stream sits at the core of Vexil's observability stack it **must** support
    /// multiple producers (flag value sources) and multiple consumers (subscribers).
    /// Fortunately, AsyncStream supports multiple consumers out of the box (with one exception,
    /// see below). And it is fairly trivial for us to collect values from multiple producers into the
    /// AsyncStream.
    ///
    /// Unfortunately, there is one small bug with `AsyncStream` in that it does not
    /// propagate the `.finished` event to all of its consumers, only the first one:
    /// https://github.com/apple/swift/issues/66541
    ///
    /// Fortunately, we don't really support finishing the stream anyway unless the `FlagPole`
    /// is deinited, which doesn't happen often.
    ///
    struct Stream {
        let currentValue: AsyncCurrentValue<FlagChange>
        let keyPathMapper: @Sendable (String) -> FlagKeyPath

        var stream: FlagChangeStream {
            currentValue.stream
        }

        init(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) {
            self.currentValue = AsyncCurrentValue(.all)
            self.keyPathMapper = keyPathMapper
        }

        func send(_ change: FlagChange) {
            currentValue.update {
                $0 = change
            }
        }

        func send(keys: Set<String>) {
            if keys.isEmpty {
                send(.all)
            } else {
                send(.some(Set(keys.map(keyPathMapper))))
            }
        }
    }

}
