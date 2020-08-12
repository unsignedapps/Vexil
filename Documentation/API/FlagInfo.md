# FlagInfo

A simple collection of information about a `Flag` or `FlagGroup`

``` swift
public struct FlagInfo
```

This is mostly used by flag editors like Vexillographer.

## Inheritance

`ExpressibleByStringLiteral`

## Initializers

### `init(description:​)`

Allows a `FlagInfo` to be initialised directly when required

``` swift
public init(description:​ String)
```

#### Parameters

  - description:​ - description:​ A brief description of the `Flag` or `FlagGroup`s purpose.

### `init(stringLiteral:​)`

``` swift
public init(stringLiteral value:​ String)
```

## Properties

### `name`

The name of the flag or flag group, if nil it is calculated from the containing property name

``` swift
var name:​ String?
```

### `description`

A brief description of the flag or flag group's purpose

``` swift
var description:​ String
```

### `shouldDisplay`

Whether or not the flag or flag group should be visible in Vexillographer

``` swift
var shouldDisplay:​ Bool
```

### `hidden`

Hides the `Flag` or `FlagGroup` from flag editors like Vexillographer

``` swift
let hidden
```
