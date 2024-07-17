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

#if canImport(os)

import Foundation
import os.lock

/// A type of lock or mutex that can be used to synchronise access
/// or execution of code by wrapping `OSAllocatedUnfairLock` (iOS 16+) or
/// `os_unfair_lock` (iOS <16).
///
/// This lock must be unlocked from the same thread that locked it, attempts to
/// unlock from a different thread will cause an assertion aborting the process.
///
/// This lock must not be accessed from multiple processes or threads via shared
/// or multiply-mapped memory, the lock implementation relies on the address of
/// the lock value and owning process.
///
struct UnfairLock<State> {

    // MARK: - Properties

    private var mutexValue: any UnfairMutex<State>

    // MARK: - Initialisation

    /// Initialise an `UnfairLock` with a non-sendable lock-protected `initialState`.
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
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            mutexValue = OSAllocatedUnfairLock<State>(uncheckedState: initialState)
        } else {
            self.mutexValue = LegacyUnfairLock.create(initialState: initialState)
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

// MARK: - Unfair Mutex

/// A private protocol that lets us work with both `OSAllocatedUnfairLock` and
/// `os_unfair_lock` depending on an #available check.
///
/// This can be removed when we drop support for iOS 15 and macOS 12, etc
///
private protocol UnfairMutex<UnfairState>: Sendable {

    associatedtype UnfairState
    func withLockUnchecked<R>(_ closure: (inout UnfairState) throws -> R) rethrows -> R
    func withLockIfAvailableUnchecked<R>(_ closure: (inout UnfairState) throws -> R) rethrows -> R?

}

// swiftlint:disable unchecked_sendable
//
// `LegacyUnfairLock` exists to help ensure thread-safety, so asserting that is Sendable here is appropriate

private final class LegacyUnfairLock<State>: ManagedBuffer<os_unfair_lock, State>, UnfairMutex, @unchecked Sendable {

    typealias UnfairState = State

    static func create(initialState: State) -> Self {
        create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointers { lockPointer, statePointer in
                lockPointer.initialize(to: os_unfair_lock())
                statePointer.initialize(to: initialState)
                return lockPointer.pointee
            }
            // not sure why a non-final class wouldn't return Self here
        } as! Self          // swiftlint:disable:this force_cast
    }

    deinit {
        withUnsafeMutablePointers { mutex, state in
            mutex.deinitialize(count: 1)
            state.deinitialize(count: 1)
        }
    }

    func withLockUnchecked<R>(_ closure: (inout UnfairState) throws -> R) rethrows -> R {
        try withUnsafeMutablePointers { mutex, state in
            os_unfair_lock_lock(mutex)
            defer {
                os_unfair_lock_unlock(mutex)
            }
            return try closure(&state.pointee)
        }
    }

    func withLockIfAvailableUnchecked<R>(_ closure: (inout UnfairState) throws -> R) rethrows -> R? {
        try withUnsafeMutablePointers { mutex, state in
            guard os_unfair_lock_trylock(mutex) else {
                return nil
            }
            defer {
                os_unfair_lock_unlock(mutex)
            }
            return try closure(&state.pointee)
        }
    }

}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension OSAllocatedUnfairLock: UnfairMutex {
    typealias UnfairState = State
}

#endif
