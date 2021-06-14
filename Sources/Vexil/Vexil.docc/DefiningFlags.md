
# Defining Flags

Defining Flags is the cornerstone of Vexil. Learn how to structure your ``FlagContainer``, use ``FlagGroup``s and ``Flag``s of various types.

## Overview

In Vexil, the definition of flags follows a similar pattern to [Swift Argument Parser][swift-argument-parser].

Vexil supports a tree of flags, so we need a structure to hold them:

```swift
import Vexil

struct LoginFlags: FlagContainer {

    @Flag("Enables the forgot password button on the login screen and associated flows")
    var forgotPassword: Bool

}
```

**Side Note:** Vexil requires descriptions for all of its flags and flag groups. This is used by Vexillographer for providing context for the flags you are enabling/disabling in the UI, but it also provides context for future developers (especially yourself in 12 months time) as to what flags mean and what their intended use is.

## Flag Groups

You can also create nested flag groups. These can live in separate files or anywhere in your code that is suitable. This allows you to structure your flags in the way that makes the most sense to you.

```swift
import Vexil

struct PasswordFlags: FlagContainer {

    @Flag("Enables or disables the change password button on the profile screen and associated flows")
    var changePassword: Bool
    
}

struct ProfileFlags: FlagContainer {

    @FlagGroup("Flags related to passwords in the profile screen")
    var password: PasswordFlags

}

struct AppFlags: FlagContainer {

    @FlagGroup("Flags that affect the login screen")
    var login: LoginFlags
    
    @FlagGroup("Flags related to the profile screen")
    var profile: ProfileFlags
    
}
```

## Flag types

So far we've only looked at basic boolean flags, but Vexil supports flags of any basic type, and almost any type that can be made `Codable`.

**Important:** All ``FlagValueSource``s that are included as part of Vexil support all types mentioned here, but some third-party providers might not support all flag types, be sure to check their documentation.

### Standard Types

You can specify your flag as an integer, double or string. Note that you need to provide a default value for your non-boolean flags.

```swift
import Vexil

struct NormalFlags: FlagContainer {

    @Flag(default: 10, "This is a demonstration Int flag")
    var myIntFlag: Int

    @Flag(default: 0.5, "This is a demonstration Double flag")
    var myDoubleFlag: Double

    @Flag(default: "Placeholder", "This is a demonstration String flag")
    var myStringFlag: String

}
```

### Enum Types

You can make any enum into a flag by conforming to ``FlagValue``, so you can specify from a list of options in your flag backend or UI. Your enum needs to be backed by a standard type (string, integer, double, etc) and/or implement `RawRepresentable` with a standard type.

If you want your enum options to appear selectable in Vexillographer you also need to conform to `CaseIterable`.

```swift
import Vexil

enum MyTheme: String, FlagValue, CaseIterable {
    case blue
    case green
    case red
}

struct ThemeFlags {

    @Flag(default: .blue, "The theme to use for the app")
    var currentTheme: MyTheme
    
}
```

### Codable Types

Vexil provides default implementations for `Codable` types, so all you need to do declare that your type conforms to ``FlagValue`` as well.

```swift
struct MyStruct: FlagValue, Codable {
    let property1: String
    let property2: Int
    let property3: String
}

struct TestFlags: FlagContainer {

    @Flag(defaultValue: MyStruct(property1: "abc123", property2: 123, property3: "🤯"), description: "...")
    var testFlag: MyStruct
    
}
```


### All Supported Flag Values

The following existing types are supported out of the box:

| Type | Notes |
|------|-----------|
| `Bool` | |
| `String` | |
| `URL` | Boxed into a string |
| `Date` | Boxed into an ISO8601 date string |
| `Data` | |
| `Float` | |
| `Double` | |
| `Int` | `Int8`, `Int16`, `Int32`, `Int64`, and their `UInt` equivalents are all supported and boxed into an `Int` |
| `RawRepresentable` | When `RawValue` is also a supported ``FlagValue`` |
| `Optional` | When `Wrapped` is also a supported ``FlagValue`` |
| `Array` | When `Element` is also a supported ``FlagValue`` |
| `Dictionary` | With `String` keys and when `Value` is also a supported ``FlagValue`` |
| `Codable` | Default implementation is provided if you declare that your `Codable` types also conform to ``FlagValue`` |

## Supporting Custom Types

In fact, any type can be used as a flag as long as it conforms to ``FlagValue``. You just need to be to box/unbox it from a simple type that the ``FlagValueSource``s support.

But be warned here, the boxing and unboxing of ``FlagValue``s is designed around what `UserDefaults` supports, and not all ``FlagValueSource` ` backends support all boxed types.

```swift
extension MyCustomType: FlagValue {
	 public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }
        
        // decode your type here
        let decoded = ...
        self = decoded
    }

    public var boxedFlagValue: BoxedFlagValue {

		 // encode your type here
        let encoded = ...
        return .string(encoded)
    }
}
```

[swift-argument-parser]: https://github.com/apple/swift-argument-parser
