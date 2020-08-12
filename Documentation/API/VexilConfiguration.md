# VexilConfiguration

A configuration struct passed into the `FlagPole` to configure it.

``` swift
public struct VexilConfiguration
```

## Initializers

### `init(codingPathStrategy:​prefix:​separator:​)`

Initialises a new `VexilConfiguration` struct with the supplied info.

``` swift
public init(codingPathStrategy:​ VexilConfiguration.CodingKeyStrategy = .default, prefix:​ String? = nil, separator:​ String = ".")
```

#### Parameters

  - codingPathStrategy:​ - codingPathStrategy:​ How to calculate each `Flag`s "key". Defaults to `CodingKeyStrategy.default` (aka `.kebabcase`)
  - prefix:​ - prefix:​ An optional prefix to apply to each calculated key,. This is treated as a separate "level" of the tree. So if your prefix is "magic", your flag keys would be `magic.abc-flag`
  - separator:​ - separator:​ A separator to use by `joined()` to combine different levels of the flag tree together.

## Properties

### `` `default` ``

The "default" `VexilConfiguration`

``` swift
var `default`:​ VexilConfiguration
```
