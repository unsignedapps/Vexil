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

/// Creates a FlagGroup with the given parameters.
///
/// All FlagGroup's must have at least a `description` which is used for future developer
/// reference and within Vexillographer, our generated flag management UI.
///
/// Attach this to a property within a `@FlagContainer`. The property's type must also
/// be a `FlagContainer`.
///
/// ```swift
/// @FlagContainer
/// struct MyFlags {
///     @FlagGroup("These flags are displayed inside a `NavigationLink` (this is the default)", display: .navigation)
///     var navigation: NavigationFlags
///
///     @FlagGroup("These flags are displayed as a `Section`", display: .section)
///     var section: SectionedFlags
/// }
///
/// @FlagContainer
/// struct NavigationFlags {
///     @Flag("First Flag")
///     var first = false
/// }
///
/// @FlagContainer
/// struct SectionedFlags {
///     @Flag("Second Flag")
///     var second = false
/// }
/// ```
///
/// - Parameters:
///   - description:        A description of this flag group. Used in flag editors like Vexillographer, and also for future developer context.
///   - display:            How the flag should be displayed in Vexillographer. Defaults to `.navigation` which wraps it in a
///                         `NavigationLink`. Other options include `.section` to wrap it in a `Section` and `.hidden`
///                         to hide it from Vexillographer entirely.
///
@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro FlagGroup(
    _ description: StaticString,
    display: FlagGroupDisplayOption = .navigation
) = #externalMacro(module: "VexilMacros", type: "FlagGroupMacro")

/// Creates a FlagGroup with the given parameters.
///
/// All FlagGroup's must have at least a `description` which is used for future developer
/// reference and within Vexillographer, our generated flag management UI.
///
/// Attach this to a property within a `@FlagContainer`. The property's type must also
/// be a `FlagContainer`.
///
/// ```swift
/// @FlagContainer
/// struct MyFlags {
///     @FlagGroup(name: "Navigation Flags", description: "These flags are displayed inside a `NavigationLink` (this is the default)", display: .navigation)
///     var navigation: NavigationFlags
///
///     @FlagGroup(name: "Section Flags", description: "These flags are displayed as a `Section`", display: .section)
///     var section: SectionedFlags
/// }
///
/// @FlagContainer
/// struct NavigationFlags {
///     @Flag("First Flag")
///     var first = false
/// }
///
/// @FlagContainer
/// struct SectionedFlags {
///     @Flag("Second Flag")
///     var second = false
/// }
/// ```
///
/// - Parameters:
///   - name:               An optional display name to give the flag group. Only visible in flag editors like Vexillographer.
///                         Default is to calculate one based on the property name.
///   - keyStrategy:        An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
///   - description:        A description of this flag group. Used in flag editors like Vexillographer, and also for future developer context.
///   - display:            How the flag should be displayed in Vexillographer. Defaults to `.navigation` which wraps it in a
///                         `NavigationLink`. Other options include `.section` to wrap it in a `Section` and `.hidden`
///                         to hide it from Vexillographer entirely.
///
@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro FlagGroup(
    _ description: StaticString
) = #externalMacro(module: "VexilMacros", type: "FlagGroupMacro")

@attached(accessor)
@attached(peer, names: prefixed(`$`))
public macro FlagGroup(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.GroupKeyStrategy = .default,
    description: StaticString,
    display: FlagGroupDisplayOption = .navigation
) = #externalMacro(module: "VexilMacros", type: "FlagGroupMacro")
