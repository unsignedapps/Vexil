# VexilConfiguration.CodingKeyStrategy

An enumeration describing how keys should be calculated by `Flag` and `FlagGroup`s.

``` swift
enum CodingKeyStrategy
```

Each `Flag` and `FlagGroup` can specify its own behaviour. This is the default behaviour
to use when they don't.

## Enumeration Cases

### `` `default` ``

Follow the default behaviour. This is basically a synonym for `.kebabcase`

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

## Methods

### `codingKey(label:​)`

``` swift
internal func codingKey(label:​ String) -> CodingKeyAction
```
