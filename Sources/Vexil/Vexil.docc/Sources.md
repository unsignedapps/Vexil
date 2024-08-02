# Flag Hierarchy

The Vexil FlagPole supports multiple backend flag sources. This guide walks through the built-in sources, how a FlagPole determines the source hierarchy and how to manipulate it.

## Overview

The Vexil `FlagPole` supports multiple backend flag sources, and ships with the following sources built-in:

| Name | Description |
|------|-------------|
| `UserDefaults` | Any `UserDefaults` instance automatically conforms to ``FlagValueSource`` |
| `NSUbiquitousKeyValueStore` | Any `NSUbiquitousKeyValueStore` instance automatically conforms to ``FlagValueSource`` |
| ``FlagValueDictionary`` | A wrapper for a simple dictionary that is great for testing or other integrations. |
| ``Snapshot`` | All snapshots taken of a FlagPole can be used as a source. |

## Initialisation

When initialising a ``FlagPole``, it will default to a single source: `UserDefaults.standard`.

You can always be explicit if you want to use a different set of sources:

```swift
let source = MyCustomFlagValueSource()

let pole = FlagPole(hoist: MyFlags.self, sources: [ source ])
```

## Source hierarchy

Sources are maintained in an `Array` on the ``FlagPole``, and the order of the array is important – when a flag is accessed it walks the array of sources and returns the first non-nil value.

This means you can support multiple flag value sources and decide their priority. For example, you might use a remote flag value provider like [Firebase Remote Config][firebase-remote-config] but still want to use [Vexillographer][vexillographer] or the Settings bundle to let support local testers.

Another common usage is to support "Environment"-based Snapshots.

```swift
let pole = FlagPole (
    hoist: MyFlags.self,
    sources: [
       UserDefaults.standard,			// allow local overrides
       environment.flags,				// any flags specific to your environment (eg. dev/test/prod)
       MyRemoteFlagProvider()			// remote flags
    ]
)
```

Remember, if all of your sources return `nil` the Flag's default value is used.

## Updating sources

Vexil, and [Vexillographer][vexillographer], also provide a means to update or save flag values into their store using Snapshots.

```swift
import Vexil

let flagPole = FlagPole(hoist: AppFlags.self)

let snapshot = flagPole.emptySnapshot()
snapshot.profile.password.changePassword = false

// save that to our user defaults, or any FlagValueSource
flagPole.save(snapshot: snapshot, to: UserDefaults.standard)
```


## Custom sources

To implement your own source you need only conform to the ``FlagValueSource`` protocol and implement its two key methods:

```swift
public protocol FlagValueSource {

    /// Give the source a name (for Vexillographer)
    var name: String { get }

    /// Provide a way to fetch values
    func flagValue<Value> (key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing
    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue

    #if !os(Linux)

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates
    ///
    var valuesDidChange: AnyPublisher<Void, Never>? { get }

    #endif
}
```

See our full guide on <doc:CustomSources> for more.

[firebase-remote-config]: https://firebase.google.com/docs/remote-config
[vexillographer]: Vexillographer.md
[custom-sources]: Custom-Sources.md
