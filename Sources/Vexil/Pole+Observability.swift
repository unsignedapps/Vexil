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

#if canImport(Combine)
import Combine
#endif


// MARK: - Helpers

private extension Optional {

    mutating func take() -> Optional {
        defer { self = nil }
        return self
    }

}


// MARK: - Publisher

#if canImport(Combine)

/// A Publisher that iterates over a provided `AsyncSequence`, emitting each element
/// in the sequence in turn.
///
/// Each subscriber to the `Publisher` will iterate over the sequence independently,
/// use `.multicast()` or `.shared()` if you want to share the iterator.
///
struct FlagPublisher<Elements> where Elements: _Concurrency.AsyncSequence {

    /// The `AsyncSequence` that we are publishing elements from
    let sequence: Elements

    /// Creates a new publisher from this `AsyncSequence`
    init(_ sequence: Elements) {
        self.sequence = sequence
    }

}


// MARK: - Publisher Conformance

extension FlagPublisher: Publisher {

    typealias Output = Elements.Element
    typealias Failure = Never

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Elements.Element == S.Input {
        let subscription = Subscription(sequence: sequence, downstream: subscriber)
        subscriber.receive(subscription: subscription)
    }

}


// MARK: - Subscription

extension FlagPublisher {

    final class Subscription {

        private var sequence: Elements?
        var iterator: Elements.AsyncIterator?

        let task: Lock<Task<Void, Never>?>

        private var demand: Subscribers.Demand = .none
        private var downstream: AnySubscriber<Elements.Element, Failure>?

        init<Downstream>(sequence: Elements, downstream: Downstream) where Downstream: Subscriber, Downstream.Input == Elements.Element, Downstream.Failure == Failure {
            self.sequence = sequence
            self.iterator = sequence.makeAsyncIterator()
            self.downstream = AnySubscriber(downstream)
            self.task = Lock(uncheckedState: nil)
        }

        private func start() {
            task.withLock { task in
                guard demand > 0, task == nil else {
                    return
                }
                task = Task<Void, Never> {
                    await iterate()
                }
            }
        }

        private func iterate() async {
            guard let subscriber = downstream else {
                cancel()
                return
            }

            do {
                try Task.checkCancellation()
                while demand > 0 {

                    // AsyncIteratprProtocol returns nil when we've reached the end
                    guard let element = try await iterator?.next() else {
                        subscriber.receive(completion: .finished)
                        cancel()
                        return
                    }
                    let additional = subscriber.receive(element)
                    demand -= 1
                    demand += additional
                }

            } catch is CancellationError {
                // Intentionally left blank

            } catch {
                subscriber.receive(completion: .finished)
                cancel()
            }
        }
    }

}


// MARK: - Downstream -> Sequence Messaging

extension FlagPublisher.Subscription: Subscription {

    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
        start()
    }

    func cancel() {
        sequence = nil
        iterator = nil
        task.withLock {
            $0?.cancel()
            $0 = nil
        }
        demand = .none
        downstream = nil
    }

}

#endif
