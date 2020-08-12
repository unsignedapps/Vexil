# FlagGroup

A wrapper representing a group of Feature Flags / Feature Toggles.

``` swift
@propertyWrapper public struct FlagGroup<Group>:​ Decorated, Identifiable where Group:​ FlagContainer
```

Use this to structure your flags into a tree. You can nest `FlagGroup`s as deep
as you need to and can split them across multiple files for maintainability.

The type that you wrap with `FlagGroup` must conform to `FlagContainer`.

## Inheritance

`Decorated`, `Identifiable`

## Initializers

### `init(name:​codingKeyStrategy:​description:​)`

Initialises a new `FlagGroup` with the supplied info

``` swift
public init(name:​ String? = nil, codingKeyStrategy:​ CodingKeyStrategy = .default, description:​ FlagInfo)
```

``` 
@FlagGroup(description:​ "This is a test flag group. Isn't it grand?"
var myFlagGroup:​ MyFlags
```

#### Parameters

  - name:​ - name:​ An optional display name to give the group. Only visible in flag editors like Vexillographer. Default is to calculate one based on the property name.
  - codingKeyStragey:​ - codingKeyStragey:​ An optional strategy to use when calculating the key name for this group. The default is to use the `FlagPole`s strategy.
  - description:​ - description:​ A description of this flag group. Used in flag editors like Vexillographer and also for future developer context. You can also specify `.hidden` to hide this flag group from Vexillographer.

## Properties

### `id`

All `FlagGroup`s are `Identifiable`

``` swift
let id
```

### `info`

A collection of information about this `FlagGroup` such as its display name and description.

``` swift
let info:​ FlagInfo
```

### `wrappedValue`

The `FlagContainer` being wrapped.

``` swift
var wrappedValue:​ Group
```
