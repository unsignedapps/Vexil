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

#if canImport(os)
import os.lock
#endif

struct Mutex<Value: ~Copyable>: ~Copyable, Sendable {

    // Mutex isn't supposed to use an allocation, but the tools we would need to
    // *avoid* an allocation are not available to us (we'd need to import `Builtin`,
    // which is forbidden)
    //
    // Using an allocation here makes us a reference type, but since Mutex is not
    // Copyable, it's pretty hard to *observe* that in practice.
    private let platformLock: PlatformLock<Value>

    init(_ initialValue: consuming sending Value) {
        self.platformLock = PlatformLock(initialValue)
    }

    borrowing func withLock<Result: ~Copyable>(
        _ body: (inout sending Value) throws -> sending Result
    ) rethrows -> sending Result {
        try platformLock.withLock(body)
    }

}

/// This is a lock that will use the most appropriate platform lock under the hood. On Apple platforms
/// it is effectively a wrapper around `OSAllocatedUnfairLock`. On non-Apple platforms it'll
/// use `pthread_lock` and friends.
package struct Lock<State>: Sendable {

    private let platformLock: PlatformLock<State>

    package init(uncheckedState: State) {
        nonisolated(unsafe) let initialState = uncheckedState
        self.platformLock = PlatformLock(initialState)
    }

    package init(initialState: State) where State: Sendable {
        self.platformLock = PlatformLock(initialState)
    }

    package init(_ initialState: State) where State: Sendable  {
        self.platformLock = PlatformLock(initialState)
    }

    package func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try platformLock.withLock {
            var state = $0
            do {
                let result = try body(&state)
                $0 = state
                return result
            } catch {
                $0 = state
                throw error
            }
        }
    }

    package func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R {
        try withLockUnchecked(body)
    }

}

// MARK: - Platform-specific Locking Implementations

struct PlatformLock<Value: ~Copyable> {

#if canImport(os)

    private typealias ActualPlatformLock = os_unfair_lock

    private static func createPlatformLock(_ lockPointer: UnsafeMutablePointer<ActualPlatformLock>) {
        lockPointer.initialize(to: os_unfair_lock())
    }

    private static func destroyPlatformLock(_ lockPointer: UnsafeMutablePointer<ActualPlatformLock>) {
        // os_unfair_lock doesn't have a destructor (which also means that it can't check that
        // it's not locked when it's destroyed, which seems like a bad thing...
        lockPointer.deinitialize(count: 1)
    }

    private static func withPlatformLock<R: ~Copyable, E: Error>(
        _ lockPointer: UnsafeMutablePointer<ActualPlatformLock>,
        _ valuePointer: UnsafeMutablePointer<Disconnected<Value>>,
        _ body: (inout sending Value) throws(E) -> sending R
    ) throws(E) -> sending R {
        os_unfair_lock_lock(lockPointer)
        defer {
            os_unfair_lock_unlock(lockPointer)
        }
        return try valuePointer.pointee.withValue(body)
    }

#else

    private typealias ActualPlatformLock = pthread_mutex_t

    private static func createPlatformLock(_ lockPointer: UnsafeMutablePointer<ActualPlatformLock>) {
        // can't explicitly manipulate the initialized/deinititalized state of
        // the memory, when using pthread_mutex_init. That should be conceptual
        // and a no-op, but if a debug layer ever makes it count for something,
        // this might break. I have no idea how to fix it in that case, though...
        let error = pthread_mutex_init(lockPointer, nil)
        // pthread_mutex_init can only fail with ENOMEM, which we don't generally
        // expect to recover from, so we can explicitly crash here.
        precondition(error == 0, "Error \(error) creating pthread_mutex")
    }

    private static func destroyPlatformLock(_ lockPointer: UnsafeMutablePointer<ActualPlatformLock>) {
        // can't explicitly manipulate the initialized/deinititalized state of
        // the memory, when using pthread_mutex_destroy. That should be conceptual
        // and a no-op, but if a debug layer ever makes it count for something,
        // this might break. I have no idea how to fix it in that case, though...
        pthread_mutex_destroy(lockPointer)
    }

    private static func withPlatformLock<R: ~Copyable, E: Error>(
        _ lockPointer: UnsafeMutablePointer<ActualPlatformLock>,
        _ valuePointer: UnsafeMutablePointer<Disconnected<Value>>,
        _ body: (inout sending Value) throws(E) -> sending R
    ) throws(E) -> sending R {
        let error = pthread_mutex_lock(lockPointer)
        // pthread_mutex_lock can only fail with EDEADLK, which the os_unfair_lock
        // variants crash for, so we can and should crash too.
        precondition(error == 0, "Error \(error) locking pthread_mutex")
        defer {
            let error = pthread_mutex_unlock(lockPointer)
            // pthread_mutex_unlock can only fail with EPERM, and only if this thread
            // doesn't already hold the lock. Since everything here is synchronous,
            // and we only have this closure-based locking function, that should
            // be impossible.
            precondition(error == 0, "Error \(error) unlocking pthread_mutex")
        }
        return try valuePointer.pointee.withValue(body)
    }

#endif

    // ManagedBuffer is frankly insane, but it's a good way to ensure we have a single heap
    // allocation containing both the lock and the state, and that we can hook into deinit
    // to ensure that the PlatformLock and State both get correctly destroyed.
    //
    // It's horrible to use, but without it, we either have to accept a second allocation,
    // or drop down to runtime magic.
    private final class LockBuffer: ManagedBuffer<ActualPlatformLock, Disconnected<Value>> {

        deinit {
            withUnsafeMutablePointers { lockPointer, statePointer in
                PlatformLock.destroyPlatformLock(lockPointer)
                statePointer.deinitialize(count: 1)
            }
        }

    }

    private let lockBuffer: ManagedBuffer<ActualPlatformLock, Disconnected<Value>>

    init(_ initialValue: consuming sending Value) {
        var initialValue = Disconnected(Optional(initialValue))
        self.lockBuffer = LockBuffer.create(minimumCapacity: 1, makingHeaderWith: { buffer in
            buffer.withUnsafeMutablePointers { lockPointer, valuePointer in
                PlatformLock.createPlatformLock(lockPointer)
                valuePointer.initialize(to: Disconnected(initialValue.take()!))
                // this is gross, we can't really create pthread_mutex by value,
                // since there's no particular guarantee that a *moved* pthread_mutex
                // is still valid, but ManagedBuffer requires us to return a value
                // here. So we initialize the pthread_mutex in-place, then return
                // the same value from this closure, which ManagedBuffer then uses
                // to overwrite the value we set (with the same bytes, for no change).
                // Ugh.
                return lockPointer.pointee
            }
        })
    }

    func withLock<R: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending R
    ) throws(E) -> sending R {
        // `withUnsafeMutablePointers` doesn't handle `sending` result types, so we
        // transfer the result inside a `Disconnected` to appease the compiler.
        try lockBuffer.withUnsafeMutablePointers { lockPointer, valuePointer throws(E) in
            try Disconnected(PlatformLock.withPlatformLock(lockPointer, valuePointer, body))
        }
        .consume()
    }

}

// Safe to be `Sendable` because `state` is accessible
// only via the `withLock` method, which wraps the access
// in `withPlatformLock`.
extension PlatformLock: @unchecked Sendable {}

// MARK: - Disconnected

private struct Disconnected<Value: ~Copyable>: ~Copyable, @unchecked Sendable {
    private nonisolated(unsafe) var value: Value

    init(_ value: consuming sending Value) {
        self.value = value
    }

#if compiler(>=6.2)
    /// Swift 6.2 may miscompile `consume()` when inlined.
    @inline(never)
#endif
    consuming func consume() -> sending Value {
        value
    }

    mutating func swap(_ other: consuming sending Value) -> sending Value {
        let result = value
        self = Disconnected(other)
        return result
    }

#if compiler(>=6.2)
    mutating func take() -> sending Value where Value: ExpressibleByNilLiteral & SendableMetatype {
        swap(nil)
    }
#else
    mutating func take() -> sending Value where Value: ExpressibleByNilLiteral {
        swap(nil)
    }
#endif

    mutating func withValue<R: ~Copyable, E: Error>(
        _ work: (inout sending Value) throws(E) -> sending R
    ) throws(E) -> sending R {
        try work(&value)
    }

}
