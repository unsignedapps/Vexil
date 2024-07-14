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

/// Creates a flag with the specified configuration.
///
/// All Flags must be initialised with a default value and a description.
/// The default value is used when none of the sources on the `FlagPole`
/// have a value specified for this flag. The description is used for future
/// developer reference and in Vexlliographer to describe the flag.
///
/// The type that you wrap with `@Flag` must conform to `FlagValue`.
///
/// You can access flag details and observe flag value changes using a peer
/// property prefixed with `$`.
///
/// ```swift
/// @Flag(default: false, description: "My magical flag")
/// var magicFlag: Bool
///
/// // Subscribe to flag updates
/// for try await magic in $magicFlag {
///     // Do magic thing
/// }
///
/// // Also works with Combine
/// $magicFlag
///     .sink { magic in
///         // Do magic thing
///     }
/// ```
///
/// - Parameters:
///   - name:               An optional display name to give the flag. Only visible in flag editors like Vexillographer.
///                         Default is to calculate one based on the property name.
///   - keyStrategy:        An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
///   - default:            The default value for this `Flag` should no sources have it set.
///   - description:        A description of this flag. Used in flag editors like Vexillographer,
///                         and also for future developer context.
///   - display:            How the flag should be displayed in Vexillographer. Defaults to `.default`,
///                         you can set it to `.hidden` to hide the flag.
///
@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag<Value: FlagValue>(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    default initialValue: Value,
    description: StaticString,
    display: FlagDisplayOption = .default
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")

/// Creates a flag with the specified configuration.
///
/// All Flags must be initialised via the property and include a description.
/// The default value is used when none of the sources on the `FlagPole`
/// have a value specified for this flag. The description is used for future
/// developer reference and in Vexlliographer to describe the flag.
///
/// The type that you wrap with `@Flag` must conform to `FlagValue`.
///
/// You can access flag details and observe flag value changes using a peer
/// property prefixed with `$`.
///
/// ```swift
/// @Flag("My magical flag")
/// var magicFlag = false
///
/// // Subscribe to flag updates
/// for try await magic in $magicFlag {
///     // Do magic thing
/// }
///
/// // Also works with Combine
/// $magicFlag
///     .sink { magic in
///         // Do magic thing
///     }
/// ```
///
/// - Parameters:
///   - description:        A description of this flag. Used in flag editors like Vexillographer,
///
@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag(
    _ description: StaticString
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")

/// Creates a flag with the specified configuration.
///
/// All Flags must be initialised via the property and include a description.
/// The default value is used when none of the sources on the `FlagPole`
/// have a value specified for this flag. The description is used for future
/// developer reference and in Vexlliographer to describe the flag.
///
/// The type that you wrap with `@Flag` must conform to `FlagValue`.
///
/// You can access flag details and observe flag value changes using a peer
/// property prefixed with `$`.
///
/// ```swift
/// @Flag(name: "Magic", description: "My magical flag")
/// var magicFlag = false
///
/// // Subscribe to flag updates
/// for try await magic in $magicFlag {
///     // Do magic thing
/// }
///
/// // Also works with Combine
/// $magicFlag
///     .sink { magic in
///         // Do magic thing
///     }
/// ```
///
/// - Parameters:
///   - name:               An optional display name to give the flag. Only visible in flag editors like Vexillographer.
///                         Default is to calculate one based on the property name.
///   - keyStrategy:        An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
///   - description:        A description of this flag. Used in flag editors like Vexillographer,
///                         and also for future developer context.
///   - display:            How the flag should be displayed in Vexillographer. Defaults to `.default`,
///                         you can set it to `.hidden` to hide the flag.
///
@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro Flag(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    description: StaticString,
    display: FlagDisplayOption = .default
) = #externalMacro(module: "VexilMacros", type: "FlagMacro")
