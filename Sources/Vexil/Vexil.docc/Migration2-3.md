# Migration Guide: v2 to v3

In version 3.0 Vexil underwent a significant refactor in order to improve performance
and memory utilisation. While a number of these changes were under the hood they do
require changes to how you have previously used Vexil and include several source-breaking
changes.

## Overview

Originally, in order to avoid significant amounts of boilerplate, Vexil made heavy use of
reflection (with [Mirror](https://developer.apple.com/documentation/Swift/Mirror) to interact
with the flag hierarchy. While the reflection information was cached it was still a heavy
performance penalty for larger flag hierarchies. There was also a large amount of value type
copying going on, resulting in a larger than desired memory footprint.

In Vexil 3, we make use of [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
to generate conformance to the [Visitor Pattern](https://en.wikipedia.org/wiki/Visitor_pattern). And like
SwiftUI, Vexil 3 creates structs as required instead of copying them around everywhere, reducing overall
memory consumption.

## Minimum Version

Vexil 3 has been rewritten from the ground up to make heavy use of Swift Macros and Structured
Concurrency. As such as has the following minimum supported requirements:

### Development Environment

- Swift 5.10
- Xcode 15.4+

### Operating Systems

- iOS 15.0 (previously 13.0)
- macOS 12.0 (previously 10.15)
- tvOS 15.0 (previously 13.0)
- watchOS 8.0 (previously 6.0)
- visionOS 1.0
- Linux variants supporting Swift 5.10+

## Flag Declarations

The largest change is to how flag hierarchies are declared, consider the following example:

```swift
// Vexil 2
struct MyFlags: FlagContainer {

    @Flag(default: false, description: "Test flag that does something magical")
    var testFlag: Bool

    @FlagGroup(description: "Some nested flags")
    var nested: NestedFlags

}

// Vexil 3
@FlagContainer
struct MyFlags {

    @Flag(default: false, description: "Test flag that does something magical")
    var testFlag: Bool

    @FlagGroup(description: "Some nested flags")
    var nested: NestedFlags

}
```

As you can see, the main change is moving `FlagContainer` from a protocol to a macro.
There are also minor changes to `@Flag` and `@FlagGroup`, which were rewritten as macros
from property wrappers.

### Flag Containers

The most visible change is the ``FlagContainer(generateEquatable:)`` macro. The `FlagContainer`
protocol is still in use, but it has different requirements now. When adopting Vexil 3 you will
see the following warning:

```swift
struct MyFlags: FlagContainer {         // Type 'MyFlags' does not conform to protocol 'FlagContainer'

    // Flags here

    // Vexil 2 FlagContainer initialiser
    init() {}

}
```

To migrate this container to Vexil 3, remove the empty initialiser and attach the `@FlagContainer` macro:

```swift
@FlagContainer
struct MyFlags {

    // Flags here

}
```

The macro will attach and generate the ``FlagContainer`` protocol conformance and its visitor pattern
requirements.

### Flag Groups

In Vexil 2, `@FlagGroup` was a property wrapper with the following initialiser:

```swift
FlagContainer.init(
    name: String? = nil,
    codingKeyStrategy: CodingKeyStrategy = .default,
    description: FlagInfo,
    display: Display = .navigation
)
```

Under Vexil 3, this is now a macro:

```swift
public macro FlagGroup(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.GroupKeyStrategy = .default,
    description: StaticString,
    display: VexilDisplayOption = .navigation
)
```

As you can see the changes here purely for simplification: `codingKeyStrategy`
was shortened to `keyStrategy`, and the description and display parameters
were refined. Previously, to hide a `@FlagGroup` from Vexillographer you
could set your description to `.hidden`; now you pass `.hidden` to display:

```swift
// Vexil 2
@FlagGroup(description: .hidden)
var nested: NestedFlags

// Vexil 3
@FlagGroup(description: "Nested flags", display: .hidden)
var nested: NestedFlags
```

### Flags

Much like Flag Groups, the `@Flag` property wrapper was replaced with the
``Flag(name:keyStrategy:default:description:)`` macro, with simplified parameters:

```swift
// Vexil 2

@Flag(default: false, description: "Flag that enables magic")
var magic: Bool

@Flag(description: "Flag that enables magic")
var magic = false

// Vexil 3

@Flag(default: false, description: "Flag that enables magic")
var magic: Bool

@Flag("Flag that enables magic")
var magic = false
```

You can see the full breadth of changes by comparing the signatures. Under Vexil 2
there are two initialisers of the property wrapper:

```swift
// Explicit default: parameter
init(
    name: String? = nil,
    codingKeyStrategy: CodingKeyStrategy = .default,
    default initialValue: Value,
    description: FlagInfo
)

// Sets default via property initialiser
init(
    wrappedValue: Value,
    name: String? = nil,
    codingKeyStrategy: CodingKeyStrategy = .default,
    description: FlagInfo
)
```

Both approaches are available via the `@Flag` macro:

```swift
/// Explicit default parameter
macro Flag<Value: FlagValue>(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    default initialValue: Value,
    description: StaticString,
    display: FlagDisplayOption = .default
)

/// Sets default via property initialiser
macro Flag(
    name: StaticString? = nil,
    keyStrategy: VexilConfiguration.FlagKeyStrategy = .default,
    description: StaticString,
    display: FlagDisplayOption = .default
)

/// There is also an even more minimal macro
macro Flag(_ description: StaticString)
```

Same as with the `FlagGroup`, the `codingKeyStrategy` parameter has been shortened
to `keyStrategy`, and the ability to hide flags has been moved to the `display` property.

## Flag Pole Observation

Under Vexil 2, every time a `FlagValueSource` reported a flag value change, we would
take a snapshot of the `FlagPole` and refresh all of the values that changed, before
publishing that snapshot. This is inefficient.

```swift
// Vexil 2

// Subscribe to changes of the whole flag pole
flagPole.publisher
    .sink { snapshot in
        // Do something
    }
```

Under Vexil 3, we offer a few different publishers depending on what you're looking to do.

```swift
// Takes and publishes a snapshot of flag values at the time any of our sources changes.
// This is the same behaviour as Vexil 2
flagPole.snapshotPublisher
    .sink { snapshot in
        // Do something
    }

// Publishes a new instance of the `RootGroup` every time any of our sources changes.
// Unlike a snapshot, accessing values on the `RootGroup` is done lazily as required.
flagPole.flagPublisher
    .sink { flags in
        // Do something
    }

// Publishes a raw stream of `FlagChange`s that you can react to.
flagPole.changePublisher
    .sink { changes in
        // Do something with the list of flags that have changed
    }
```

These are also available as `AsyncSequence`s.

```swift
for await snapshot in flagPole.snapshots {
    // Do something with each snapshot of the flag pole
}

for await flags in flagPole.flags {
    // Do something with each RootGroup
}

for await change in flagPole.changes {
    // Do something with each FlagChange
}
```

## Flag Observation

Under Vexil 2 you could subscribe to a single flag via the projected property (ie `$someFlag.publisher`).
This would wrap the `FlagPole`'s publisher so was equally as inefficient.

```swift
// Subscribe to changes of a single flag
flagPole.$someFlag.publisher
    .sink { value in
        // Do something
    }
```

Under Vexil 3 you can access the same functionality by subscribing to the generated peer property directly.
This subscribes to the list of changes under the hood so it can defer fetching and comparing values until
it knows it has changed. It's also available as an `AsyncSequence`.

```swift
// Subscribe to changes of a single flag
flagPole.$someFlag
    .sink { value in
        // Do something with value
    }

// You can also iterate directly over it
for await value in flagPole.$someFlag {
    // Do something with value
}
```

## Vexillographer

Vexillographer is not yet available under Vexil 3.

## Flag Diagnostics

Flag Diagnostic support is not yet available under Vexil 3. 
