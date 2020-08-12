# Types

  - [VexilConfiguration](/VexilConfiguration):​
    A configuration struct passed into the `FlagPole` to configure it.
  - [VexilConfiguration.CodingKeyStrategy](/VexilConfiguration_CodingKeyStrategy):​
    An enumeration describing how keys should be calculated by `Flag` and `FlagGroup`s.
  - [FlagGroup.CodingKeyStrategy](/FlagGroup_CodingKeyStrategy):​
    An enumeration describing how the key should be calculated for this specific `FlagGroup`.
  - [Flag.CodingKeyStrategy](/Flag_CodingKeyStrategy):​
    An enumeration describing how the key should be calculated for this specific `Flag`.
  - [Flag](/Flag):​
    A wrapper representing a Feature Flag / Feature Toggle.
  - [FlagInfo](/FlagInfo):​
    A simple collection of information about a `Flag` or `FlagGroup`
  - [FlagGroup](/FlagGroup):​
    A wrapper representing a group of Feature Flags / Feature Toggles.
  - [FlagPole](/FlagPole):​
    A `FlagPole` hoists a group of feature flags / feature toggles.
  - [MutableFlagGroup](/MutableFlagGroup):​
    A `MutableFlagGroup` is a wrapper type that provides a "setter" for each contained `Flag`.
  - [Snapshot](/Snapshot):​
    A `Snapshot` serves multiple purposes in Vexil. It is a point-in-time container of flag values, and is also
    mutable and can be applied / saved to a `FlagValueSource`.
  - [BoxedFlagValue](/BoxedFlagValue):​
    An intermediate type used to make encoding and decoding of types simpler for `FlagValueSource`s

# Protocols

  - [FlagContainer](/FlagContainer):​
    A `FlagContainer` is a type that encapsulates your `Flag` and `FlagGroup`
    types. The only requirement of a `FlagContainer` is that it can be initialised
    with an empty `init()`.
  - [FlagValueSource](/FlagValueSource):​
    A simple protocol that describes a source of `FlagValue`s
  - [FlagValue](/FlagValue)
  - [FlagDisplayValue](/FlagDisplayValue)
