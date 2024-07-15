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
struct POSIXThreadLock<State>: Mutex {

    private var mutexValue: POSIXMutex<State>

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
        self.mutexValue = .create(uncheckedState: initialState) { mutex in
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

}

// MARK: - POSIX mutex

// `POSIXMutex` exists to help ensure thread-safety, so asserting that is Sendable here is appropriate

private final class POSIXMutex<State>: ManagedBuffer<pthread_mutex_t, State>, @unchecked Sendable {

    static func create(
        uncheckedState initialState: State,
        mutexInitializer: (UnsafeMutablePointer<pthread_mutex_t>) -> Void
    ) -> Self {
        create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointers { mutex, state in
                state.initialize(to: initialState)
                mutexInitializer(mutex)
                return mutex.pointee
            }
            // not sure why a non-final class wouldn't return Self here
        } as! Self
    }

    deinit {
        withUnsafeMutablePointers { mutex, state in
            state.deinitialize(count: 1)

            // can't explicitly manipulate the initialized/deinititalized state of
            // the memory, when using pthread_mutex_destroy. That should be conceptual
            // and a no-op, but if a debug layer ever makes it count for something,
            // this might break. I have no idea how to fix it in that case, though...
            pthread_mutex_destroy(mutex)
        }
    }

    func withLockUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R {
        try withUnsafeMutablePointers { mutex, state in
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
        try withUnsafeMutablePointers { mutex, state in
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
