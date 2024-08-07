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

import Foundation

/// A type of lock or mutex that can be used to synchronise access or
/// execution of code by wrapping `pthread_mutex_lock` and `pthread_mutex_unlock`
///
/// This lock must be unlocked from the same thread that locked it, attempts to
/// unlock from a different thread will cause an assertion aborting the process.
///
/// - Important: If you're using async/await or Structured Concurrency consider
/// using an `actor` instead of these locks.
///
struct POSIXThreadLock<State>: Sendable {

    private let mutexValue: POSIXMutex<State>

    /// Initialise the Mutex with a non-sendable lock-protected `initialState`.
    ///
    /// By initialising with a non-sendable type, the owner of this structure
    /// must ensure the Sendable contract is upheld manually.
    /// Non-sendable content from `State` should not be allowed
    /// to escape from the lock.
    ///
    /// - Parameter
    ///   - initialState: An initial value to store that will be protected under the lock.
    ///
    init(uncheckedState initialState: State) {
        self.mutexValue = .init(uncheckedState: initialState) { mutex in
            // can't explicitly manipulate the initialized/deinititalized state of
            // the memory, when using pthread_mutex_init. That should be conceptual
            // and a no-op, but if a debug layer ever makes it count for something,
            // this might break. I have no idea how to fix it in that case, though...
            let error = pthread_mutex_init(mutex, nil)

            // pthread_mutex_init can only fail with ENOMEM, which we don't generally
            // expect to recover from, so we can explicitly crash here.
            precondition(error == 0, "Could not initialise a pthread_mutex, this usually indicates a serious problem with system resources")
        }
    }

    /// Initialise the Mutex with a lock-protected sendable `initialState`.
    ///
    /// - Parameter
    ///   - initialState: An initial value to store that will be protected under the lock.
    ///
    init(initialState: State) where State: Sendable {
        self.init(uncheckedState: initialState)
    }

    /// Perform a closure while holding this lock.
    ///
    /// This method does not enforce sendability requirement on closure body and its return type.
    /// The caller of this method is responsible for ensuring references to non-sendables from closure
    /// uphold the Sendability contract.
    ///
    /// - Parameters:
    ///   - closure:    A closure to invoke while holding this lock.
    /// - Returns:      The return value of `closure`.
    /// - Throws:       Anything thrown by `closure`.
    ///
    func withLockUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R {
        try mutexValue.withLockUnchecked(closure)
    }

    ///  Perform a sendable closure while holding this lock.
    ///
    /// - Parameters:
    ///   - closure:    A sendable closure to invoke while holding this lock.
    /// - Returns:      The return value of `closure`.
    /// - Throws:       Anything thrown by `closure`.
    ///
    func withLock<R>(_ closure: @Sendable (inout State) throws -> R) rethrows -> R where R: Sendable {
        try withLockUnchecked(closure)
    }

    /// Attempt to acquire the lock, if successful, perform a closure while holding the lock.
    ///
    /// This method does not enforce sendability requirement on closure body and its return type.
    /// The caller of this method is responsible for ensuring references to non-sendables from closure
    /// uphold the Sendability contract.
    ///
    /// - Parameters:
    ///   - closure:    A sendable closure to invoke while holding this lock.
    /// - Returns:      The return value of `closure`.
    /// - Throws:       Anything thrown by `closure`.
    ///
    func withLockIfAvailableUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R? {
        try mutexValue.withLockIfAvailableUnchecked(closure)
    }

    ///  Attempt to acquire the lock, if successful, perform a sendable closure while
    ///  holding the lock.
    ///
    /// - Parameters:
    ///   - closure:    A sendable closure to invoke while holding this lock.
    /// - Returns:      The return value of `closure`.
    /// - Throws:       Anything thrown by `closure`.
    ///
    func withLockIfAvailable<R>(_ closure: @Sendable (inout State) throws -> R) rethrows -> R? where R: Sendable {
        try withLockIfAvailableUnchecked(closure)
    }

}

// MARK: - POSIX mutex

private final class POSIXMutex<State>: @unchecked Sendable {

    let buffer: ManagedBuffer<pthread_mutex_t, State>

    init(
        uncheckedState initialState: State,
        mutexInitializer: (UnsafeMutablePointer<pthread_mutex_t>) -> Void
    ) {
        self.buffer = .create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointers { mutex, state in
                state.initialize(to: initialState)
                mutexInitializer(mutex)
                return mutex.pointee
            }
        }
    }

    deinit {
        buffer.withUnsafeMutablePointers { mutex, state in
            state.deinitialize(count: 1)

            // can't explicitly manipulate the initialized/deinititalized state of
            // the memory, when using pthread_mutex_destroy. That should be conceptual
            // and a no-op, but if a debug layer ever makes it count for something,
            // this might break. I have no idea how to fix it in that case, though...
            pthread_mutex_destroy(mutex)
        }
    }

    func withLockUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { mutex, state in
            let result = pthread_mutex_lock(mutex)
            precondition(result == 0, "Error \(result) locking pthread_mutex")

            defer {
                let result = pthread_mutex_unlock(mutex)
                precondition(result == 0, "Error \(result) unlocking pthread_mutex")
            }

            return try closure(&state.pointee)
        }
    }

    func withLockIfAvailableUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R? {
        try buffer.withUnsafeMutablePointers { mutex, state in
            let result = pthread_mutex_trylock(mutex)
            precondition(result == 0 || result == EBUSY, "Error \(result) trying to lock pthread_mutex")
            guard result == 0 else {
                return nil
            }

            defer {
                let result = pthread_mutex_unlock(mutex)
                precondition(result == 0, "Error \(result) unlocking pthread_mutex")
            }

            return try closure(&state.pointee)
        }
    }

}
