# Flag

A wrapper representing a Feature Flag / Feature Toggle.

``` swift
@propertyWrapper public struct Flag<Value>:​ Decorated, Identifiable where Value:​ FlagValue
```

All `Flag`s must be initialised with a default value and a description.
The default value is used when none of the sources on the `FlagPole`
have a value specified for this flag. The description is used for future
developer reference and in Vexlliographer to describe the flag.

The type that you wrap with `@Flag` must conform to `FlagValue`.

The wrapper returns itself as its `projectedValue` property in case
you need to acess any information about the flag itself.

Note that `Flag`s are immutable. If you need to mutate this flag use a `Snapshot`.

## Inheritance

`Decorated`, `Identifiable`

## Initializers

### `init(name:​codingKeyStrategy:​default:​description:​)`

Initialises a new `Flag` with the supplied info.

``` swift
public init(name:​ String? = nil, codingKeyStrategy:​ CodingKeyStrategy = .default, default initialValue:​ Value, description:​ FlagInfo)
```

You must at least provide a `default` value and `description` of the flag:​

``` 
@Flag(default:​ false, description:​ "This is a test flag. Isn't it nice?")
var myFlag:​ Bool
```

#### Parameters

  - name:​ - name:​ An optional display name to give the flag. Only visible in flag editors like Vexillographer. Default is to calculate one based on the property name.
  - codingKeyStrategy:​ - codingKeyStrategy:​ An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
  - default:​ - default:​ The default value for this `Flag` should no sources have it set.
  - description:​ - description:​ A description of this flag. Used in flag editors like Vexillographer, and also for future developer context. You can also specify `.hidden` to hide this flag from Vexillographer.

## Properties

### `id`

All `Flag`s are `Identifiable`

``` swift
var id
```

### `info`

A collection of information about this `Flag`, such as its display name and description.

``` swift
var info:​ FlagInfo
```

### `defaultValue`

The default value for this `Flag` for when no sources are available, or if no
sources have a value specified for this flag.

``` swift
var defaultValue:​ Value
```

### `wrappedValue`

The `Flag` value. This is a calculated property based on the `FlagPole`s sources.

``` swift
var wrappedValue:​ Value
```

### `key`

The string-based Key for this `Flag`, as calculated during `init`. This key is
sent to  the `FlagValueSource`s.

``` swift
var key:​ String
```

### `projectedValue`

A reference to the `Flag` itself is available as a projected value, in case you need
access to the key or other information.

``` swift
var projectedValue:​ Flag<Value>
```
