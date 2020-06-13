# Vexil

Vexil (named for [Vexillology][vexillology]) is a Swift package for managing feature flags (or feature toggles) in a flexible, multi-provider way.

![CI][ci-badge]

## Features

* Define your flags in a structured tree
* Extensible to support any backend flag storage or platform
* Take and apply snapshots of flag states
* Vexillographer: A simple SwiftUI interface for editing flags

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

### Flag Groups

You can also create nested flag groups:

```swift
import Vexil

struct PasswordFlags: FlagContainer {

    @Flag("Enables or disables the change password button on the profile screen and associated flows")
    var changePassword: Bool
    
}

struct ProfileFlags: FlagContainer {

    @FlagGroup("Flags related to passwords in the profile screen")
    var password: PasswordFlags

}

struct AppFlags: FlagContainer {

    @FlagGroup("Flags that affect the login screen")
    var login: LoginFlags
    
    @FlagGroup("Flags related to the profile screen")
    var profile: ProfileFlags
    
}
```

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

By default access to flags on the FlagPole is immutable from your source code. This is a deliberate design decision: flags should not be easily mutatable from your app as it can lead to mistake (eg. `flag = true` instead of `flag == true`).

That said, it is still very easy to mutate any flags if you need to using a snapshot:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

var snapshot = Snapshot(hoist: AppFlags.self)
snapshot.profile.password.changePassword = true

flagPole.apply(snapshot: snapshot)
```

For more info see [Snapshots](#snapshots).

### Flag types

So far we've only looked at basic boolean flags, but Vexil supports flags of any basic type, and almost any type that can be made `Codable`.

**Important:** All providers that are included as part of Vexil support all types mentioned here, but some third-party providers might not support all flag types, be sure to check their documentation.

#### Standard Types

You can specify your flag as an integer, double or string. Note that you need to provide a default value for your non-boolean flags.

```swift
import Vexil

struct NormalFlags: FlagContainer {

    @Flag(default: 10, "This is a demonstration Int flag")
    var myIntFlag: Int

    @Flag(default: 0.5, "This is a demonstration Double flag")
    var myDoubleFlag: Double

    @Flag(default: "Placeholder", "This is a demonstration String flag")
    var myStringFlag: String

}
```

#### Enum Types

You can make any enum into a flag, so you can specify from a list of options in your flag backend or UI. Your enum needs to be backed by a standard type (string, integer, double, etc) and/or implement `RawRepresentable` with a standard type.

If you want your enum options to appear selectable in Vexillographer you also need to conform to `CaseIterable`.

```swift
import Vexil

enum MyTheme: String, CaseIterable {
    case blue
    case green
    case red
}

struct ThemeFlags {

    @Flag(default: .blue, "The theme to use for the app")
    var currentTheme: MyTheme
    
}
```

#### Other Types

In fact, any type can be used as a flag as long as it conforms to `ExpressibleByFlag`, the primary concern of which is to be `Codable`. But be warned here, not all `FlagPoleProvider` backends support storing custom flags.

## Configurable providers

The Vexil FlagPole supports multiple backend flag storage providers. To implement your own provider you need only conform to the `FlagPoleProvider` protocol and implement its two key methods:

```swift
public protocol FlagPoleProvider {
    func flagValue (key: String) -> FlagValue?
    func setFlagValue (_ value: FlagValue?, key: String)
    
    // Note: This may end up being like Codable where we have to support a bunch of
    // generated overloaded functions because generic protocols aren't great right now
}
```

### Built-in providers

Vexil ships with the following providers built-in:

| Name | Description |
|------|-------------|
| `UserDefaults` | Any `UserDefaults` instance automatically conforms to `FlagPoleProvider` |
| `ArgumentParserProvider` | (via [Vexil-cli][vexil-cli]) Lets you set the values of your keys for your command line apps. |
| `SnapshotProvider` | A collection of mutable snapshots of the values of Flags that can be applied to a FlagPole. See [Snapshots](#snapshots) below |

## Snapshots

Vexil provides a mechanism to mutate, save, load and apply snapshots of flag states and values.

**Important:** Snapshots only reflect values and states _that have been mutated_. That is, a snapshot is only applied to values that have been explicitly set within it. Any values that have not been set will defer to the next provider in the list, or the default value. The exception is when you take a _full snapshot_ of a FlagPole, which captures the value of every flag.

Snapshots are implemented as a `FlagPoleProvider`, so you can easily apply multiple snapshots in a prioritised order.

### Creating snapshots

You can manually create snapshots and specify which flags are affected:

```swift
import Vexil

// create a manual empty snapshot
var snapshot = Snapshot(hoist: AppFlags.self)

// update some values and states
snapshot.login.forgotPassword = false
snapshot.$profile.password = false

// apply that snapshot - only the two values above will change
flagPole.apply(snapshot: snapshot)
```

You can also take a snapshot of the current state of your FlagPole:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// snapshot the current state - this will get the state of *all* flags
let fullSnapshot = Snapshot(of: flagPole)

// you can also just snapshot any flag that has been overridden locally
let partialSnapshot = Snapshot(of: flagPole, localOverridesOnly: true)

// save them, mutate them, whatever you like
// ...
```

### Saving snapshots to a provider

Because snapshots are implemented as a provider themelves, they sit as a layer above your existing providers and don't actually modify them.

If you have another provide you want to save your snapshot too (such as `UserDefaults`), use the second parameter of `FlagPole.apply(snapshot:to:)`:

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

// snapshot any flag that has been overridden locally
let snapshot = Snapshot(of: flagPole, localOverridesOnly: true)

// save that to our user defaults
flagPole.apply(snapshot: snapshot, to: UserDefaults.standard)
```

There is also the convenience method `FlagPole.save(to:)` which simplifies this for you.

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

# Vexillographer: A SwiftUI Flag Manipulation Tool

The second library product of Vexil is Vexillographer, a small SwiftUI tool for displaying and manipulating flags. You include it in your project somewhere and initialise it with a FlagPole:

```swift
import Vexillographer

struct MyView: View {

    @State var flagPole = FlagPole(hoist: AppFlags.swift)
    
    var body: some View {
        Vexillographer(flagPole: flagPole)
    }
    
}
```

Vexillographer will then display a `NavigationView` that lists all of your Flags and FlagGroups, allowing you to drill down your configured flags and edit their values directly.

## Where to put Vexillographer

While you can include Vexillographer in your app hidden behind some secret gesture or conditional compilation or feature flag technique (mind that inception), we strongly recommend you don't do this.

Instead, create a separate app and using [App Groups][app-groups] setup [shared user defaults][shared-userdefaults] between it and your app. You can use that shared `UserDefaults` as your main `FlagPoleProvider`, or you can include multiple ones to keep local overrides separate.

## Installing Vexillographer

_TODO_

## Contributing

We welcome all contributions! Please read the [Contribution Guide](CONTRIBUTING.md) for details on how to get started.

## License

Vexil is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[ci-badge]: https://github.com/unsignedapps/Vexil/workflows/Tests/badge.svg
[vexillology]: https://en.wikipedia.org/wiki/Vexillology
[swift-argument-parser]: https://github.com/apple/swift-argument-parser
[vexil-cli]: https://github.com/unsignedapps/Vexil-cli
[app-groups]: https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups
[shared-userdefaults]: https://medium.com/ios-os-x-development/shared-user-defaults-in-ios-3f15cd2c9409