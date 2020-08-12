# MutableFlagGroup

A `MutableFlagGroup` is a wrapper type that provides a "setter" for each contained `Flag`.

``` swift
@dynamicMemberLookup public class MutableFlagGroup<Group, Root> where Group:​ FlagContainer, Root:​ FlagContainer
```
