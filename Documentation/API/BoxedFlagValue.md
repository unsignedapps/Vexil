# BoxedFlagValue

An intermediate type used to make encoding and decoding of types simpler for `FlagValueSource`s

``` swift
public enum BoxedFlagValue
```

## Inheritance

`Equatable`

## Enumeration Cases

### `array`

``` swift
case array(:​ [BoxedFlagValue])
```

### `bool`

``` swift
case bool(:​ Bool)
```

### `dictionary`

``` swift
case dictionary(:​ [String:​ BoxedFlagValue])
```

### `data`

``` swift
case data(:​ Data)
```

### `double`

``` swift
case double(:​ Double)
```

### `float`

``` swift
case float(:​ Float)
```

### `integer`

``` swift
case integer(:​ Int)
```

### `none`

``` swift
case none
```

### `string`

``` swift
case string(:​ String)
```
