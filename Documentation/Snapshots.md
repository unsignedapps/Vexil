# Snapshots

<!-- summary: "This guide takes you through Snapshots, which are one of the most versatile features of Vexil." -->

Snapshots are one of the most versatile features of Vexil. They are used to support real-time flag monitoring using [Combine][combine] and provide the primary source of mutability to a `FlagPole`.

## Subscribing to flag changes

A key part of declarative programming is the ability to react to changes over time. Vexil supports this by declaring a `Publisher` that will deliver a `Snapshot` of the `FlagPole` any time one of its values changes.

This could be the addition or removal of a `FlagValueSource` or one of those sources reporting the change. Either way, a new `Snapshot` will be delivered that you can subscribe to.

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

**Note:** If the type of your `Flag` also conforms to `Equatable`, the flag-specific publisher will emit the value only when it has changed (using `removeDuplicates()`). If your `Flag` does not conform to `Equatable` it will skip removing the duplicates and emit every time the `FlagPole` changes.

## Mutating the FlagPole

Having the `FlagPole` be immutable directly was a deliberate design decision. It prevents a category of programming mistakes (eg. `flagPole.myFlag = true`), but it also keeps the API simple and easy to reason about.

That said - mutating the `FlagPole` is still very straight forward as each `Snapshot` also conforms to `FlagValueSource` - that means it can be added into your `FlagPole`'s source hierarchy in any position:

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

// create an empty Snapshot and change the values we want
let snapshot = flagPole.emptySnapshot()
snapshot.subgroup.myBooleanFlag = true

// insert that snapshot at the top of the hierarchy so it overrides all the rest
flagPole.insert(snapshot: snapshot, at: 0)
```

The source hierarchy is also accessible via `FlagPole._sources` if you want to manipulate it directly.

## Mutating a FlagValueSource

`Snapshot`s also provide a way to modify a `FlagValueSource`, so you could use it whenever you need to update the `UserDefaults`, for example. This is the same capability [Vexillographer][vexillographer] uses to provide its flag editing user interface.

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

// create an empty Snapshot and change the values we want
let snapshot = flagPole.emptySnapshot()
snapshot.subgroup.myBooleanFlag = true

// save that to the UserDefaults
try flagPole.save(snapshot: snapshot, to: UserDefaults.standard)
```

## How Snapshots work

You can think of `Snapshot`s as a simple mutable dictionary of flag values. It is literally a `[String: Any]` where the string key corresponds to the flag's key, and the value is the Flag's value. It then uses the same logic as a `FlagPole` in routing requests for the flag's value to the internal dictionary.

This follows the design philosophy in Vexil that a `FlagValueSource` should only return a value if it has been explicitly set in that source, and should otherwise return `nil` to allow the next `FlagValueSource` to be consulted.

### Creating Snapshots

There are two ways to create a `Snapshot`, empty or full.

#### Empty Snapshots

When taking an empty snapshot, its internal dictionary is also empty, and the request for the Flag's value (when used as a `FlagValueSource`) will be `nil`. If you access the `Flag.wrappedValue` property directly (eg. `flagPole.subgroup.myBooleanFlag`) it will return the flag's **default value**.

Empty snapshots are typically used for mutating the `FlagPole` or a `FlagValueSource`.

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

let snapshot = flagPole.emptySnapshot()
```

#### Full Snapshots

When taking a full snapshot, the `FlagPole` will walk the flag hierarchy and copy the current value of every flag into the `Snapshot`, so the internal dictionary will contain every flag key => value currently known.

Full snapshots are used by the `FlagPole`'s `Publisher` when emitting changes.

```swift
let flagPole = FlagPole(hoist: MyFlags.self)

let snapshot = flagPole.snapshot()
```


[combine]: https://developer.apple.com/documentation/combine
[vexillographer]: Vexillographer.md