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

public struct FlagChangeStream: AsyncSequence, Sendable {

    public typealias Element = FlagChange
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public typealias Failure = Never

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(allocation: allocation)
    }

    weak var allocation: AsyncCurrentValue<FlagChange>.Allocation?

}


// MARK: - AsyncIterator

public extension FlagChangeStream {

    struct AsyncIterator: AsyncIteratorProtocol {

        weak var allocation: AsyncCurrentValue<FlagChange>.Allocation?
        var generation = 0

        public mutating func next() async -> Element? {
            // is `#isolation` or `nil` better here?
            await next(isolation: #isolation)
        }

        public mutating func next(isolation actor: isolated (any Actor)?) async -> Element? {
            guard let allocation else {
                return nil
            }
            let uuid = UUID()
            let generationAndResult = await withTaskCancellationHandler {
                await withCheckedContinuation { (continuation: CheckedContinuation<(Int, Element)?, Never>) in
                    allocation.mutex.withLock {
                        if Task.isCancelled {
                            // the iterating task is already cancelled, just return nil
                            continuation.resume(returning: nil)
                        } else if $0.generation > generation {
                            // the `CurrentValue` already has a newer value, just return it
                            continuation.resume(returning: ($0.generation, $0.wrappedValue))
                        } else {
                            // wait for the `CurrentValue` to be updated
                            $0.pendingContinuations.append((uuid, continuation))
                        }
                    }
                }
            } onCancel: {
                allocation.mutex.withLock {
                    if let index = $0.pendingContinuations.firstIndex(where: { $0.0 == uuid }) {
                        $0.pendingContinuations.remove(at: index).1.resume(returning: nil)
                    } else {
                        // onCancel: was called before operation:
                        // operation: will discover that Task.isCancelled
                    }
                }
            }
            guard let generationAndResult else {
                return nil
            }
            // ensure we don't return a duplicate value next time
            generation = generationAndResult.0
            return generationAndResult.1
        }
    }

}
