# FlagPole

A `FlagPole` hoists a group of feature flags / feature toggles.

``` swift
@dynamicMemberLookup public class FlagPole<RootGroup> where RootGroup:​ FlagContainer
```

It provides the primary mechanism for dynamically accessing `Flag`s, looking
them up from multiple sources. It also provides methods for taking and interaction
with `Snapshot`s of flags.

Each `FlagPole` must be initalised with the type of a `FlagContainer`:​

``` 
struct MyFlags:​ FlagContainer {
    // ...
}

let flagPpole = FlagPole(hoist:​ MyFlags.self)
```

You can then interact with the `FlagPole` using dynamic member lookup:​

``` 
if flagPole.myFlag == true { ... }
```

> 

## Initializers

### `init(hoist:​configuration:​sources:​)`

Initialises a `FlagPole` with the supplied info.

``` swift
public convenience init(hoist:​ RootGroup.Type, configuration:​ VexilConfiguration = .default, sources:​ [FlagValueSource]? = nil)
```

At minimum you need to provide a type that contains all of your `Flag` and `FlagGroup`s that conforms to `FlagContainer`.
You can also specify how flag keys should be calculated and an array of flag value sources.

#### Parameters

  - hoist:​ - hoist:​ The type of `FlagContainer` to hoist. eg. `MyFlags.self`
  - configuration:​ - configuration:​ An optional configuration describing how `Flag` keys should be calculated. Defaults to `VexilConfiguration.default`
  - sources:​ - sources:​ An optional Array of `FlagValueSource`s to use as the flag pole's source hierarchy. Defaults to `FlagPole.defaultSources`

## Properties

### `_configuration`

The configuration information supplied to the `FlagPole` during initialisation.

``` swift
let _configuration:​ VexilConfiguration
```

### `_sources`

An Array of `FlagValueSource`s that are used during flag value lookup.

``` swift
var _sources:​ [FlagValueSource]
```

This array is mutable so you can manipulate it directly whenever your
need to change the hierarchy of your flag sources.

The order of this Array is the order used when looking up flag values.

### `defaultSources`

The default sources to use when they are not specified during `init()`.

``` swift
var defaultSources:​ [FlagValueSource]
```

The current default sources include:​

  - `UserDefaults.standard`

### `_rootGroup`

The "Root Group" that  contains your Flag tree/hierarchy.

``` swift
var _rootGroup:​ RootGroup
```

### `publisher`

<dl>
<dt><code>!os(Linux)</code></dt>
<dd>

A `Publisher` that can be used to monitor flag value changes in real-time.

``` swift
var publisher:​ AnyPublisher<Snapshot<RootGroup>, Never>
```

A new `Snapshot` is emitted every time a flag value changes. The snapshot
contains the latest state of all flag values in the tree.

</dd>
</dl>

## Methods

### `snapshot()`

Creates a `Snapshot` of the current state of the `FlagPole`

``` swift
public func snapshot() -> Snapshot<RootGroup>
```

The value of each `Flag` within the `FlagPole` is copied into the snapshot.

### `emptySnapshot()`

Creates an empty `Snapshot` of the current `FlagPole`.

``` swift
public func emptySnapshot() -> Snapshot<RootGroup>
```

The snapshot itself will be empty and access to any flags
within the snapshot will return the flag's `defaultValue`.

### `insert(snapshot:​at:​)`

Inserts a `Snapshot` into the `FlagPole`s source hierarchy at the specified index.

``` swift
public func insert(snapshot:​ Snapshot<RootGroup>, at index:​ Array<FlagValueSource>.Index)
```

Inserting a snapshot at the top of the hierarchy (eg at index `0`) is a good way to
override the values in the FlagPole without saving it to a source, but you can also
insert it anywhere in the hierarchy you need.

> 

#### Parameters

  - snapshot:​ - snapshot:​ The `Snapshot` to be inserted
  - at:​ - at:​ The index at which to insert the `Snapshot`.

### `append(snapshot:​)`

Appends a `Snapshot` to the end of the `FlagPole`s source hierarchy.

``` swift
public func append(snapshot:​ Snapshot<RootGroup>)
```

> 

#### Parameters

  - snapshot:​ - snapshot:​ The `Snapshot` to be added to the source hierarchy.

### `remove(snapshot:​)`

Removes a `Snapshot` from the `FlagPole`s source hierarchy.

``` swift
public func remove(snapshot:​ Snapshot<RootGroup>)
```

> 

#### Parameters

  - snapshot:​ - snapshot:​ The `Snapshot` to be removed from the source hierarchy.

### `save(snapshot:​to:​)`

Saves the specified `Snapshot` to the specified `FlagValueSource`.

``` swift
public func save(snapshot:​ Snapshot<RootGroup>, to source:​ FlagValueSource) throws
```

Only the values that are specifically included in the `Snapshot` will be saved.
When you create a snapshot using `FlagPole.snapshot()`, all values are copied into the `Snapshot`.

If you created your snapshot using `FlagPole.emptySnapshot()`, no values are included. Only values that
subsequently **changed** using the dynamic member lookup support would then be saved to `source`:​

``` 
// Create an empty snapshot
let snapshot = flagPole.emptySnapshot()

// Change any flags you need to
snapshot.subgroup.showMyTestFeature = true

// Save that back to `UserDefaults`. Only `subgroup.show-my-test-feature` will be saved.
try flagPole.save(snapshot:​ snapshot, to:​ UserDefaults.standard)
```

#### Parameters

  - snapshot:​ - snapshot:​ The `Snapshot` to save to the source. Only the values included in the snapshot will be saved.
  - to:​ - to:​ The `FlagValueSource` to save the snapshot to.
