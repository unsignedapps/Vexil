# ``Vexil``

Vexil (named for Vexillology) is a Swift package for managing feature flags (also called feature toggles) in a flexible, multi-provider way.

## Overview

![Vexil flag logo](vexil.png)

* Define your flags in a structured tree
* Extensible to support any backend flag storage or platform
* Take and apply snapshots of flag states
* Get real-time flag updates using Combine
* Vexillographer: A simple SwiftUI interface for editing flags

### Defining Flags

If you've ever used [swift-argument-parser] defining flags in Vexil will be a familiar experience.

Vexil supports a tree of flags, so we need a structure to hold them:

```swift
import Vexil

struct LoginFlags: FlagContainer {

    @Flag("Enables the forgot password button on the login screen and associated flows")
    var forgotPassword: Bool

}
```

**Side Note:** Vexil requires descriptions for all of its flags and flag groups. This is used by Vexillographer for providing context for the flags you are enabling/disabling in the UI, but it also provides context for future developers (especially yourself in 12 months time) as to what flags mean and what their intended use is.

See the [full documentation for how to define flags](<doc:DefiningFlags>) to read more

### Checking flags

To check your flags, you need to run them up a ``FlagPole``:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// should we show the change password screen?
if flagPole.profile.password.changePassword {
    // ...
}
```

### Mutating flags

By default access to flags on the ``FlagPole`` is immutable from your source code. This is a deliberate design decision: flags should not be easily mutable from your app as it can lead to mistakes (eg. `flag = true` instead of `flag == true`).

That said, it is still very easy to mutate any flags if you need to using a snapshot:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

var snapshot = flagPole.emptySnapshot()
snapshot.profile.password.changePassword = true

// insert it at the top of the hierarchy
flagPole.insert(snapshot: snapshot, at: 0)
```

For more info see <doc:Snapshots>.

## Flag Value Sources

The Vexil `FlagPole` supports multiple backend flag sources, and ships with the following sources built-in:

| Name | Description |
|------|-------------|
| `UserDefaults` | Any `UserDefaults` instance automatically conforms to ``FlagValueSource`` |
| `Snapshot` | All snapshots taken of a ``FlagPole`` can be used as a source. |

See the full documentation on <doc:CustomSources> for more on working with sources and how to define your own.


## Snapshots

Vexil provides a mechanism to mutate, save, load and apply snapshots of flag states and values.

**Important:** Snapshots only reflect values and states _that have been mutated_. That is, a snapshot is only applied to values that have been explicitly set within it. Any values that have not been set will defer to the next source in the list, or the default value. The exception is when you take a _full snapshot_ of a FlagPole, which captures the value of every flag.

Snapshots are implemented as a ``FlagValueSource``, so you can easily apply multiple snapshots in a prioritised order.

Snapshots can do a lot. See our [Snapshots Guide](<doc:Snapshots>) for more.

## Creating snapshots

You can manually create snapshots and specify which flags are affected:

```swift
import Vexil

// create an empty snapshot
var snapshot = flagPole.emptySnapshot()

// update some values and states
snapshot.login.forgotPassword = false
snapshot.profile.password = false

// apply that snapshot - only the two values above will change
flagPole.insert(snapshot: snapshot, at: 0)
```

You can also take a snapshot of the current state of your ``FlagPole``:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// snapshot the current state - this will get the state of *all* flags
let snapshot = flagPole.snapshot()

// save them, mutate them, whatever you like
// ...
```


## Topics

### The Flag Pole

- ``FlagPole``
- ``VexilConfiguration``
- <doc:Sources>
- <doc:FlagPublishing>
- <doc:FlagKeys>

### Flags

- <doc:DefiningFlags>
- ``Flag``
- ``FlagValue``

### Flag Groups

- ``FlagGroup``
- ``FlagContainer``

### Snapshots

- <doc:Snapshots>
- ``Snapshot``
- ``MutableFlagGroup``

### Sources

Vexil includes support for a number of sources out of the box, including `UserDefaults` and `NSUbiquitousKeyValueStore`. You can also create your own sources by conforming to ``FlagValueSource``.

- <doc:CustomSources>
- ``FlagValueSource``
- ``FlagValueDictionary``
- ``BoxedFlagValue``

### Supporting Types

- ``FlagDisplayValue``
- ``FlagInfo``

### Diagnostics

- <doc:Diagnostics>
- ``FlagPoleDiagnostic``

[swift-argument-parser]: https://github.com/apple/swift-argument-parser
