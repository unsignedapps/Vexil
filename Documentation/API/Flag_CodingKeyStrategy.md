# Flag.CodingKeyStrategy

An enumeration describing how the key should be calculated for this specific `Flag`.

``` swift
enum CodingKeyStrategy
```

## Enumeration Cases

### `` `default` ``

Follow the default behaviour applied to the `FlagPole`

``` swift
case `default`
```

### `kebabcase`

Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name

``` swift
case kebabcase
```

### `snakecase`

Converts the property name into a snake\_case string. e.g. myPropertyName becomes my\_property\_name

``` swift
case snakecase
```

### `customKey`

Manually specifies the key name for this `Flag`.

``` swift
case customKey(:​ String)
```

This is combined with the keys from the parent groups to create the final key.

### `customKeyPath`

Manually specifices a fully qualified key path for this flag.

``` swift
case customKeyPath(:​ String)
```

This is the absolute key name. It is NOT combined with the keys from the parent groups.

## Methods

### `codingKey(label:​)`

``` swift
internal func codingKey(label:​ String) -> CodingKeyAction
```
