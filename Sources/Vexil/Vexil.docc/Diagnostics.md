# Diagnostics

Debug issues with flag resolutions and real-time updates using diagnostics.

## Overview

A Vexil ``FlagPole`` is flexible. But that flexibility can quickly grow into complexity if it isn't managed properly. Say you have a remote flag provider like Launch Darkly or Firebase Remote Config, as well as allowing your testers to override flag values via `UserDefaults`, and maybe you like to have some pre-defined flags for each of your non-production environments. How do you know what your flag values are at any one time and why? Especially when your app is running on a user's device.

## Point-in-time diagnostics

Vexil provides diagnostics in two places. The first allows you to inspect the current ``FlagPole`` to see how it is currently resolving flag values.

```swift
let diagnostics = flagPole.makeDiagnostics()
print(diagnostics)

// Prints:
// Current value of flag 'flag1' is 'bool(false)'. Resolved by: Default value
// Current value of flag 'flag2' is 'bool(true)'. Resolved by: UserDefaults.standard
```

You can view them on a ``Snapshot`` too, if that snapshot was taken with diagnostics enabled.

```swift
let snapshot1 = flagPole.snapshot()
let diagnostics1 = try snapshot1.makeDiagnostics() // This snapshot was not taken with diagnostics enabled. 

let snapshot2 = flagPole.snapshot(enableDiagnostics: true)
let diagnostics2 = try snapshot2.makeDiagnostics()
```

## Real-time diagnostics

Vexil also supports capturing real-time diagnostics alongside the real-time flag publishing. Every time a flag value is changed somewhere in your flag hierarchy, a diagnostic will be emitted that tells you which flag source initiated the change, and how the flag is resolving.

```swift
let diagnosticsPublisher = flagPole.makeDiagnosticsPublisher()

diagnosticsPublisher.sink { diagnostic in
	print(diagnostic)
}

// prints
// Current value of flag 'flag1' is 'bool(false)'. Resolved by: Default value
// Current value of flag 'flag2' is 'bool(false)'. Resolved by: Default value
// Value of flag `flag2` was changed to `bool(true)` by UserDefaults.standard. Resolved by: UserDefaults.standard

```

## Performance impact

Diagnostics aren't free – we keep an additional boxed copy of each ``FlagValue`` in memory in addition to its raw value. This is so that when we hand you the diagnostics you can make sense of them without needing to undo the type-erasure, which requires access to the Generic information stored in your flag hierarchy.

## Topics

### Diagnostics

- ``FlagPoleDiagnostic``
- ``FlagPole/makeDiagnostics()``
- ``FlagPole/makeDiagnosticsPublisher()``
- ``Snapshot/makeDiagnostics()``
