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


// MARK: - Publisher

#if canImport(Combine)

/// A Publisher that iterates over a provided `AsyncSequence`, emitting each element
/// in the sequence in turn.
///
/// Each subscriber to the `Publisher` will iterate over the sequence independently,
/// use `.multicast()` or `.shared()` if you want to share the iterator.
///
struct FlagPublisher<Elements>: Sendable where Elements: _Concurrency.AsyncSequence & Sendable, Elements.Element: Sendable {

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

    final class Subscription: Sendable {

        private struct State {
            var task: Task<Void, Never>?
            var demand = Subscribers.Demand.none
            var downstream: AnySubscriber<Elements.Element, Failure>?
        }

        let sequence: Elements
        private let state: Lock<State>

        init<Downstream>(sequence: Elements, downstream: Downstream) where Downstream: Subscriber, Downstream.Input == Elements.Element, Downstream.Failure == Failure {
            self.sequence = sequence
            self.state = .init(uncheckedState: State(downstream: AnySubscriber(downstream)))
        }

        private func start(additionalDemand: Subscribers.Demand = .none) {
            state.withLock { state in
                state.demand += additionalDemand

                guard state.demand > 0, state.task == nil else {
                    return
                }
                state.task = Task<Void, Never> {
                    await send()
                }
            }
        }

        private func send() async {
            guard let (subscriber, demand) = getSubscriberAndDemand(), demand > 0, Task.isCancelled == false else {
                return
            }

            do {
                for try await element in sequence {
                    // If we were cancelled just bail out
                    if Task.isCancelled {
                        return
                    }

                    // Send the value to the receiver
                    let additionalDemand = subscriber.receive(element)

                    // Calculate current demand
                    let stillHasDemand = state.withLock { state in
                        state.demand -= 1
                        state.demand += additionalDemand
                        return state.demand > 0
                    }

                    // If we don't have any demand finish the current task
                    if stillHasDemand == false {
                        state.withLock {
                            $0.task = nil
                        }
                        return
                    }
                }

            } catch {
                subscriber.receive(completion: .finished)
                cleanup()
            }
        }

        private func getSubscriberAndDemand() -> (AnySubscriber<Elements.Element, Failure>, Subscribers.Demand)? {
            state.withLockUnchecked { state in
                guard let subscriber = state.downstream else {
                    cleanup(state: &state)
                    return nil
                }
                return (subscriber, state.demand)
            }
         }

        private func cleanup() {
            state.withLock {
                cleanup(state: &$0)
            }
        }
        private func cleanup(state: inout State) {
            state.task?.cancel()
            state.task = nil
            state.demand = .none
            state.downstream = nil
        }

    }

}


// MARK: - Downstream -> Sequence Messaging

extension FlagPublisher.Subscription: Subscription {

    nonisolated func request(_ demand: Subscribers.Demand) {
        start(additionalDemand: demand)
    }

    nonisolated func cancel() {
        cleanup()
    }

}

#endif
