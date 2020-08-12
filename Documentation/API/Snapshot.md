# Snapshot

A `Snapshot` serves multiple purposes in Vexil. It is a point-in-time container of flag values, and is also
mutable and can be applied / saved to a `FlagValueSource`.

``` swift
@dynamicMemberLookup public class Snapshot<RootGroup>:​ FlagValueSource where RootGroup:​ FlagContainer
```

`Snapshot`s are themselves a `FlagValueSource`, which means you can insert in into a `FlagPole`s
source hierarchy as required.,

You create snapshots using a `FlagPole`:​

``` 
// Create an empty Snapshot. It contains no values itself so any flags
// accessed in it will use their `defaultValue`.
let empty = flagPole.emptySnapshot()

// Create a full Snapshot. The current value of *all* flags in the `FlagPole`
// will be copied into it.
let snapshot = flagPole.snapshot()
```

Snapshots can be manipulated:​

``` 
snapshot.subgroup.myAmazingFlag = "somevalue"
```

Snapshots can be saved or applied to a `FlagValueSource`:​

``` 
try flagPole.save(snapshot:​ snapshot, to:​ UserDefaults.standard)
```

Snapshots can be inserted into the `FlagPole`s source hierarchy:​

``` 
flagPole.insert(snapshot:​ snapshot, at:​ 0)
```

And Snapshots are emitted from a `FlagPole` when you subscribe to real-time flag updates:​

``` 
flagPole.publisher
    .sink { snapshot in
        // ...
    }
```

## Inheritance

`Equatable`, [`FlagValueSource`](/FlagValueSource)

## Properties

### `id`

All `Snapshot`s are `Identifiable`

``` swift
let id
```

### `displayName`

An optional display name to use in flag editors like Vexillographer.

``` swift
var displayName:​ String?
```

### `name`

``` swift
var name:​ String
```

## Methods

### `flagValue(key:​)`

``` swift
public func flagValue<Value>(key:​ String) -> Value? where Value:​ FlagValue
```

### `setFlagValue(_:​key:​)`

``` swift
public func setFlagValue<Value>(_ value:​ Value?, key:​ String) throws where Value:​ FlagValue
```

### `==(lhs:​rhs:​)`

``` swift
public static func ==(lhs:​ Snapshot, rhs:​ Snapshot) -> Bool
```
