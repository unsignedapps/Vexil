//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation
import os.lock

/// Describes a type that can be used as a lock, mutex or general
/// synchronisation primitive. It can enforce limited access to a
/// resource in multi-threaded environments.
protocol Mutex<State>: Sendable {

    /// An internal state that can be stored and protected by the mutex.
    associatedtype State

    // MARK: - Initialisation

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
    init(uncheckedState initialState: State)

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
    func withLockUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R

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
    func withLockIfAvailableUnchecked<R>(_ closure: (inout State) throws -> R) rethrows -> R?

}


// MARK: - Sendable conveniences

extension Mutex {

    /// Initialise the Mutex with a lock-protected sendable `initialState`.
    ///
    /// - Parameter
    ///   - initialState: An initial value to store that will be protected under the lock.
    ///
    init(initialState: State) where State: Sendable {
        self.init(uncheckedState: initialState)
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
