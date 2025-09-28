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

import Foundation

struct AsyncCurrentValue<Wrapped: Sendable>: Sendable {

    struct State {
        // iterators start with generation = 0, so our initial value
        // has generation 1, so even that will be delivered.
        var generation = 1
        var wrappedValue: Wrapped {
            didSet {
                generation += 1
                for (_, continuation) in pendingContinuations {
                    continuation.resume(returning: (generation, wrappedValue))
                }
                pendingContinuations = []
            }
        }

        var pendingContinuations = [(UUID, CheckedContinuation<(Int, Wrapped)?, Never>)]()
    }

    final class Allocation: Sendable {
        let mutex: Mutex<State>

        init(state: sending State) {
            self.mutex = Mutex(state)
        }
    }

    // MARK: - Properties

    let allocation: Allocation

    // get-only; providing set would encourage `currentValue += 1`
    // which is a race (lock taken twice). Use
    // `$currentValue.update { $0 += 1 }` instead.

    /// Access to the current value.
    var value: Wrapped {
        allocation.mutex.withLock { $0.wrappedValue }
    }

    // MARK: - Initialisation

    /// Creates a `CurrentValue` with an initial value
    init(_ initialValue: sending Wrapped) {
        self.allocation = .init(state: State(wrappedValue: initialValue))
    }

    // MARK: - Mutation

    /// Updates the current state using the supplied closure.
    ///
    /// - Parameters:
    ///   - body:               A closure that passes the current value as an in-out parameter that you can mutate.
    ///                         When the closure returns the mutated value is saved as the current value and is sent to all subscribers.
    ///
    func update<R: Sendable>(_ body: (inout sending Wrapped) throws -> R) rethrows -> R {
        try allocation.mutex.withLock { state in
            var wrappedValue = state.wrappedValue
            do {
                let result = try body(&wrappedValue)
                state.wrappedValue = wrappedValue
                return result
            } catch {
                state.wrappedValue = wrappedValue
                throw error
            }
        }
    }

}

extension AsyncCurrentValue<FlagChange> {
    var stream: FlagChangeStream {
        FlagChangeStream(allocation: allocation)
    }
}
