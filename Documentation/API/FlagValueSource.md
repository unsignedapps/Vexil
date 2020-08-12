# FlagValueSource

A simple protocol that describes a source of `FlagValue`s

``` swift
public protocol FlagValueSource
```

For more information and examples on creating custom `FlagValueSource`s please
see the full documentation.

## Requirements

## name

The name of the source. Used by flag editors like Vexillographer

``` swift
var name:​ String
```

## flagValue(key:​)

Provide a way to fetch values

``` swift
func flagValue<Value>(key:​ String) -> Value? where Value:​ FlagValue
```

## setFlagValue(\_:​key:​)

And to save values – if your source does not support saving just do nothing

``` swift
func setFlagValue<Value>(_ value:​ Value?, key:​ String) throws where Value:​ FlagValue
```

## valuesDidChange

<dl>
<dt><code>!os(Linux)</code></dt>
<dd>

If you're running on a platform that supports Combine you can optionally support real-time
flag updates

``` swift
var valuesDidChange:​ AnyPublisher<Void, Never>?
```

</dd>
</dl>
