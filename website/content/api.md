# Types

  - [VexilConfiguration](VexilConfiguration.md):​
    A configuration struct passed into the `FlagPole` to configure it.
  - [VexilConfiguration.CodingKeyStrategy](VexilConfiguration_CodingKeyStrategy.md):​
    An enumeration describing how keys should be calculated by `Flag` and `FlagGroup`s.
  - [FlagGroup.CodingKeyStrategy](FlagGroup_CodingKeyStrategy.md):​
    An enumeration describing how the key should be calculated for this specific `FlagGroup`.
  - [Flag.CodingKeyStrategy](Flag_CodingKeyStrategy.md):​
    An enumeration describing how the key should be calculated for this specific `Flag`.
  - [Flag](Flag.md):​
    A wrapper representing a Feature Flag / Feature Toggle.
  - [FlagInfo](FlagInfo.md):​
    A simple collection of information about a `Flag` or `FlagGroup`
  - [FlagGroup](FlagGroup.md):​
    A wrapper representing a group of Feature Flags / Feature Toggles.
  - [FlagPole](FlagPole.md):​
    A `FlagPole` hoists a group of feature flags / feature toggles.
  - [MutableFlagGroup](MutableFlagGroup.md):​
    A `MutableFlagGroup` is a wrapper type that provides a "setter" for each contained `Flag`.
  - [Snapshot](Snapshot.md):​
    A `Snapshot` serves multiple purposes in Vexil. It is a point-in-time container of flag values, and is also
    mutable and can be applied / saved to a `FlagValueSource`.
  - [FlagValueDictionary](FlagValueDictionary.md):​
    A simple dictionary-backed FlagValueSource that can be useful for testing
    and other purposes.
  - [BoxedFlagValue](BoxedFlagValue.md):​
    An intermediate type used to make encoding and decoding of types simpler for `FlagValueSource`s

# Protocols

  - [FlagContainer](FlagContainer.md):​
    A `FlagContainer` is a type that encapsulates your `Flag` and `FlagGroup`
    types. The only requirement of a `FlagContainer` is that it can be initialised
    with an empty `init()`.
  - [FlagValueSource](FlagValueSource.md):​
    A simple protocol that describes a source of `FlagValue`s
  - [FlagValue](FlagValue.md):​
    A type that represents the wrapped value of a `Flag`
  - [FlagDisplayValue](FlagDisplayValue.md):​
    A convenience protocol used by flag editors like Vexillographer.
