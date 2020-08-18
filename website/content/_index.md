---
toc: true
---


![Vexil][vexil-logo]

<p align="center">Vexil (named for <a href="https://en.wikipedia.org/wiki/Vexillology">Vexillology</a>) is a Swift package for managing feature flags <br />(also called feature toggles) in a flexible, multi-provider way.</p>

<p align="center">
	<img src="https://github.com/unsignedapps/Vexil/workflows/Tests/badge.svg">
	<a href="https://sonarcloud.io/dashboard?id=unsignedapps_Vexil"><img src="https://sonarcloud.io/api/project_badges/measure?project=unsignedapps_Vexil&metric=alert_status"></a>
</p>

## Features

* Define your flags in a structured tree
* Extensible to support any backend flag storage or platform
* Take and apply snapshots of flag states
* Get real-time flag updates using Combine
* Vexillographer: A simple SwiftUI interface for editing flags

## Documentation

In addition to this README, which covers basic usage and installation, you can find more documentation:

- On our documentation website: [https://unsignedapps.github.io/Vexil/](https://unsignedapps.github.io/Vexil/)
- Detailed documentation and guides in the [Documentation](Documentation) subdirectory

## Usage

### Defining Flags

If you've ever used [swift-argument-parser][swift-argument-parser] defining flags in Vexil will be a familiar experience.

Vexil supports a tree of flags, so we need a structure to hold them:

```swift
import Vexil

struct LoginFlags: FlagContainer {

    @Flag("Enables the forgot password button on the login screen and associated flows")
    var forgotPassword: Bool

}
```

**Side Note:** Vexil requires descriptions for all of its flags and flag groups. This is used by [Vexillographer](#vexillographer-a-swiftui-flag-manipulation-tool) for providing context for the flags you are enabling/disabling in the UI, but it also provides context for future developers (especially yourself in 12 months time) as to what flags mean and what their intended use is.

See the [full documentation for how to define flags][defining-flags] to read more

### Checking flags

To check your flags, you need to run them up a Flag Pole:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// should we show the change password screen?
if flagPole.profile.password.changePassword {
    // ...
}
```

### Mutating flags

By default access to flags on the FlagPole is immutable from your source code. This is a deliberate design decision: flags should not be easily mutatable from your app as it can lead to mistakes (eg. `flag = true` instead of `flag == true`).

That said, it is still very easy to mutate any flags if you need to using a snapshot:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

var snapshot = flagPole.emptySnapshot()
snapshot.profile.password.changePassword = true

// insert it at the top of the hierarchy
flagPole.insert(snapshot: snapshot, at: 0)
```

For more info see [Snapshots](#snapshots).

## Flag Value Sources

The Vexil `FlagPole` supports multiple backend flag sources, and ships with the following sources built-in:

| Name | Description |
|------|-------------|
| `UserDefaults` | Any `UserDefaults` instance automatically conforms to `FlagValueSource` |
| `Snapshot` | All snapshots taken of a FlagPole can be used as a source. |

See the full documentation on [Flag Value Sources][flag-value-sources] for more on working with sources and how to define your own.


## Snapshots

Vexil provides a mechanism to mutate, save, load and apply snapshots of flag states and values.

**Important:** Snapshots only reflect values and states _that have been mutated_. That is, a snapshot is only applied to values that have been explicitly set within it. Any values that have not been set will defer to the next source in the list, or the default value. The exception is when you take a _full snapshot_ of a FlagPole, which captures the value of every flag.

Snapshots are implemented as a `FlagValueSource`, so you can easily apply multiple snapshots in a prioritised order.

Snapshots can do a lot. See our [Snapshots Guide][snapshots] for more.

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

You can also take a snapshot of the current state of your FlagPole:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// snapshot the current state - this will get the state of *all* flags
let snapshot = flagPole.snapshot()

// save them, mutate them, whatever you like
// ...
```

## Installing Vexil

To use Vexil in your project add it as a dependency in a Swift Package, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/unsignedapps/Vexil.git", from: "1.0.0")
]
```

And add it as a dependency of your target:

```swift
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "Vexil", package: "Vexil")
    ])
]
```

### In Xcode 11+

To use Vexil in Xcode 11 or higher, navigate to the _File_ menu and choose _Swift Packages_ -> _Add Package Dependency..._, then enter the repository URL and version details for the release as desired.

## Vexillographer: A SwiftUI Flag Manipulation Tool

The second library product of Vexil is Vexillographer, a small SwiftUI tool for displaying and manipulating flags.

<div>
    <img src="https://github.com/unsignedapps/Vexil/raw/main/Documentation/Images/Vexillographer-1.png" />
    <img src="https://github.com/unsignedapps/Vexil/raw/main/Documentation/Images/Vexillographer-2.png" />
    <img src="https://github.com/unsignedapps/Vexil/raw/main/Documentation/Images/Vexillographer-3.png" />
</div>

Read more about [Vexillographer][vexillographer].

## Contributing

We welcome all contributions! Please read the [Contribution Guide](CONTRIBUTING.md) for details on how to get started.

## License

Vexil is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[vexil-logo]: .github/vexil.png
[swift-argument-parser]: https://github.com/apple/swift-argument-parser
[vexil-cli]: https://github.com/unsignedapps/Vexil-cli

[defining-flags]: Documentation/Defining-Flags.md
[flag-value-sources]: Documentation/Sources.md
[snapshots]: Documentation/Snapshots.md
[vexillographer]: Documentation/Vexillographer.md