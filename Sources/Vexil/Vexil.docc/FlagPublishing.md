# Flag Publishing

Vexil supports real-time updates when flag values change through the use of Combine.

## Overview

A key part of declarative programming is the ability to react to changes over time. Vexil supports this by declaring a `Publisher` that will deliver a ``Snapshot`` of the ``FlagPole`` any time one of its values changes.

This could be the addition or removal of a ``FlagValueSource`` or one of those sources reporting the change. Either way, a new ``Snapshot`` will be delivered that you can subscribe to.

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

flagPole.publisher
    .sink { snapshot in
        // ... do something with the flag snapshot
    }
```

### Subscribing to individual flags

A common approach is to subscribe to an individual flag and update your app in response to any changes in that flag's value:

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

flagPole.publisher
    .map { $0.subgroup.myBooleanFlag }
    .removeDuplicates()
    .sink { flag in
        // .. do something when flag changes from false <-> true.
    }
```

An in fact Vexil provides a convenience `Publisher` for this scenario:

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

flagPole.subgroup.$myBooleanFlag.publisher
    .sink { flag in
        // .. do something when the flag value changes
    }
```

**Note:** If the type of your ``Flag`` also conforms to `Equatable`, the flag-specific publisher will emit the value only when it has changed (using `removeDuplicates()`). If your ``Flag`` does not conform to `Equatable` it will be unable to remove the duplicates and emit every time the ``FlagPole`` changes.
