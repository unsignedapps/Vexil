# Flag Keys

<!-- summary: "This guide looks in depth at how Vexil calculates the key for each of its flags, and how you can control that process." -->

Lets be honest, any Feature Flag or Feature Toggle platform is just a glorified Key-Value store, and all Vexil does is map string-based keys into a strongly-typed hierarchy and provide a (hopefully) nice developer experience.

It's very important then when working with different `FlagValueSource`s that you know how Vexil maps the `FlagContainer`, `FlagGroup` and `Flag`s into something that can work with any key-value store.

If you'd prefer to read this guide in code format check out [KeyEncodingTests.swift][tests].

## FlagPole Configuration

You choose your encoding strategy and group separator when you initialise your `FlagPole` by passing in a `VexilConfiguration` instance:

```swift
let config = VexilConfiguration(codingPathStrategy: .snakecase, separator: "/")
let flagPole = FlagPole(hoist: MyFlags.self, configuration: config)
```

### Key encoding strategy

Vexil supports a number of different strategies to encoding keys. The default approach is the `.kebabcase` encoding with period (`.`) separators.

You can find the key of a `Flag` at any time using its `key` property.

#### Kebab-case encoding

The default, the kebab-case encoding joins words in property names with dashes:

```swift
print(flagPole.subgroup.secondSubgroup.$myAwesomeFlag.key)

// outputs: "subgroup.second-subgroup.my-awesome-flag"
```

#### Snake-case encoding

Similarly, the snake-case encoding joins words in property names with underscores:

```swift
print(flagPole.subgroup.secondSubgroup.$myAwesomeFlag.key)

// outputs: "subgroup.second_subgroup.my_awesome_flag"
```

### Group separator

By default Vexil will join each level of the flag tree together with periods (`.`), but you can easily change that to anything else, like say slashes (`/`), so the kebab-case example above would become:

```swift
print(flagPole.subgroup.secondSubgroup.$myAwesomeFlag.key)

// outputs: "subgroup/second-subgroup/my-awesome-flag"
```

Which starts to look a lot like a file path.

### Prefixes

Vexil also supports an optional prefix for calculating its flag keys. So if you wanted to ensure that all feature flags in your `UserDefaults` started with a `feature.` for example, you could set the prefix to `"feature"`.

```swift
let config = VexilConfiguration(prefix: "feature")
let flagPole = FlagPole(hoist: MyFlags.self, configuration: config)

print(flagPole.subgroup.secondSubgroup.$myAwesomeFlag.key)

// outputs: "feature.subgroup.second-subgroup.my-awesome-flag"
```

## Flag Key Overrides

Sometimes though you want to override how a specific flag calculates its key. Vexil allows you to pass in a `CodingKeyStrategy` when you declare your `Flag` to alter how its key is calculated:

```swift
@Flag(codingKeyStrategy: .snakecase, default: false, description: "My Awesome Flag")
var myAwesomeFlag: Bool

// Key is "subgroup.second-subgroup.my_awesome_flag"
```

That would leave `myAwesomeFlag` calculating its key as `"subgroup.second-subgroup.my_awesome_flag"` while leaving the default behaviour of the `FlagPole` unchanged.

### Custom Key

You can also go for a manually specified key instead of a calculated one using a `CodingKeyStrategy` of `.customKey("my-key")`:

```swift
@Flag(codingKeyStrategy: .customKey("my-key"), default: false, description: "My Awesome Flag")
var myAwesomeFlag: Bool

// Key is "subgroup.second-subgroup.my-key"
```

### Custom Key Path

But sometimes your `FlagValueSource` doesn't play nice, or the people naming flags in the backend don't provide the same structure that you want your local flags to be in. You can instead set a manual key path. In this case the `FlagPole` will ignore the location of the `Flag` in the flag structure and will just use the key you specify.

```swift
@Flag(codingKeyStrategy: .customKeyPath("my-key"), default: false, description: "My Awesome Flag")
var myAwesomeFlag: Bool

// Key is "my-key"
```

## FlagGroup Overrides

While a `FlagGroup` doesn't have an explicit key of its own, it does form part of the calculated key. For example, if we declared our `MyFlags` structure as:

```swift
struct MyFlags: FlagContainer {
    
    @FlagGroup(description: "A subgroup of flags")
    var subgroup: Subgroup
    
}
```

Then `"subgroup"` would form the first part of the key as calculated in the examples above.

Similarly to the `Flag`s, we can customise the calculation of the `FlagGroup`s key by passing in a custom `CodingKeyStrategy`.

A `FlagGroup`s `CodingKeyStrategy` supports most of the same basic options as the `Flag` above (eg, `.kebabcase`, `.snakecase`, and `.customKey(String)`), but it does not support a `.customKeyPath(String)`, because it does not have its own key calculated.

### Skipping FlagGroups

It does support an additional `CodingKeyStrategy` though: `.skip`. Which will ignore that `FlagGroup`s key in the calculation:

```swift
struct MyFlags: FlagContainer {
    
    @FlagGroup(codingKeyStrategy: .skip, description: "A second-level subgroup of flags")
    var secondSubgroup: SecondSubgroup
    
}

let flagPole = FlagPole(hoist: MyFlags.self)
print(flagPole.subgroup.secondSubgroup.$myAwesomeFlag.key)

// Outputs "subgroup.my-awesome-flag"
// (the "second-subgroup" component is omitted)
```

[tests]: https://github.com/unsignedapps/Vexil/blob/main/Tests/VexilTests/KeyEncodingTests.swift