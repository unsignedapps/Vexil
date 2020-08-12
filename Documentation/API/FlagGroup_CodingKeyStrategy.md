# FlagGroup.CodingKeyStrategy

An enumeration describing how the key should be calculated for this specific `FlagGroup`.

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

### `skip`

Skips this `FlagGroup` from the key generation

``` swift
case skip
```

### `customKey`

Manually specifies the key name for this `FlagGroup`.

``` swift
case customKey(:​ String)
```

## Methods

### `codingKey(label:​)`

``` swift
internal func codingKey(label:​ String) -> CodingKeyAction
```
