# Creating Custom Flag Value Sources

<!-- summary: "This guide walks you through the basics in creating a custom FlagValueSource using the bundled sources as examples." -->

This guide will walk through the basics in creating a custom `FlagValueSource`, using the bundled sources as examples.

## The simplest source

Because a `FlagValueSource` is effectively a plain key-value dictionary, the simplest source is exactly that: a `Dictionary<String, Any>`.

There are the two methods from the protocol you need to implement: `func flagValue<Value> (key: String) -> Value?` and `func setFlagValue<Value> (_ value: Value?, key: String) throws`.

```swift
class FlagValueDictionary: FlagValueSource {

    var storage: [String: Any]

    init (_ dictionary: [String: Any] = [:]) {
        self.storage = dictionary
    }

    var name: String {
        return String(describing: Self.self)
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.storage[key] as? Value
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        if let value = value {
            self.storage.updateValue(value, forKey: key)
        } else {
            self.storage.removeValue(forKey: key)
        }
    }
}
```

Thats it.

## Real-time flag value publishing

If you're using the `Publisher`s provided by Vexil though, you'll want to make sure your custom source also notifies the `FlagPole` when it is changed. To do that there is a simple additional property in the protocol you need to implement: `var valuesDidChange: AnyPublisher<Void, Never>`.

(At the time of writing this document, Combine is still not available on Linux, so we take care in our implementation. These conditional compilation steps are omitted from the examples for brevity.)

Here is a fuller example of the `FlagValueDictionary` above.

```swift
class FlagValueDictionary: FlagValueSource {

    var storage: [String: Any] {
        didSet {
            self.subject.send()
        }
	 }

    // we use a subject + didSet instead of `@Published` because `@Published` works more like a `willSet`
    // so the Snapshot ends up not including the new values
    private var subject = PassthroughSubject()

    init (_ dictionary: [String: Any] = [:]) {
        self.storage = dictionary
    }

    var name: String {
        return String(describing: Self.self)
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.storage[key] as? Value
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        if let value = value {
            self.storage.updateValue(value, forKey: key)
        } else {
            self.storage.removeValue(forKey: key)
        }
    }
    
    var valuesDidChange: AnyPublisher<Void, Never> {
        self.subject.eraseToAnyPublisher()
    }
}
```

## Boxing flag values

But not everything can be type-erased into an `Any` so easily. Sometimes you need to be able to "box" (encode or serialise) it into a different type. For example, `UserDefaults` stores all of its values as an `NSObject` subclass.

To make this simpler, Vexil provides the `BoxedFlagValue` type, and each `FlagValue` type needs to provide an implementation for boxing and unboxing its values into a `BoxedFlagValue`. See [Defining Flags][defining] for more on creating custom flag value types.

So when creating your custom source, you don't need to be too concerned with trying to unpack the `Value` generic in your methods, you just need to work with the much simpler `BoxedFlagValue`.

```swift
public enum BoxedFlagValue: Equatable {
    case array([BoxedFlagValue])
    case bool(Bool)
    case dictionary([String: BoxedFlagValue])
    case data(Data)
    case double(Double)
    case float(Float)
    case integer(Int)
    case none
    case string(String)
}
```

### Unpacking a boxed flag value

So in your custom source, you need only provide a translation between the source's storage type and the `BoxedFlagValue`. Here is the one for `UserDefaults`:

```swift
extension BoxedFlagValue {

    /// Initialises a BoxedFlagValue from an "Any" object.
    ///
    /// It does this by attempting to cast into the specified Swift type,
    /// letting the bridging from the Objective-C types do the heavy lifting.
    ///
    /// - Parameters:
    ///   - object:			The object returned by `UserDefaults.object(forKey:)`.
    ///   - typeHint:		The generic Value type, because we can cast any `Int` into a `Bool` and sometimes we need a hint
    ///
    init?<Value> (object: Any, typeHint: Value.Type) {
        switch object {
        
        // we only try to cast to Bool if the caller is expecting a Bool
        case let value as Bool where typeHint == Bool.self:
            self = .bool(value)

        case let value as Data:             self = .data(value)
        case let value as Int:              self = .integer(value)
        case let value as Float:            self = .float(value)
        case let value as Double:           self = .double(value)
        case let value as String:           self = .string(value)
        case is NSNull:                     self = .none

        case let value as [Any]:            self = .array(value.compactMap({ BoxedFlagValue(object: $0, typeHint: typeHint) }))
        case let value as [String: Any]:    self = .dictionary(value.compactMapValues({ BoxedFlagValue(object: $0, typeHint: typeHint) }))

        default:
            return nil
        }
    }

    /// Returns the NSObject subclass that `UserDefaults` is expecting for the receiving boxed flag value
    ///
    var object: NSObject {
        switch self {
        case let .array(value):         return value.map({ $0.object }) as NSArray
        case let .bool(value):          return value as NSNumber
        case let .data(value):          return value as NSData
        case let .dictionary(value):    return value.mapValues({ $0.object }) as NSDictionary
        case let .double(value):        return value as NSNumber
        case let .float(value):         return value as NSNumber
        case let .integer(value):       return value as NSNumber
        case .none:                     return NSNull()
        case let .string(value):        return value as NSString
        }
    }
}
```

### Implementing FlagValueSource

Once we have that translation between a `BoxedFlagValue` and `NSObject` done, the rest of implementing `FlagValueSource` for `UserDefaults` becomes pretty simple:

```swift
extension UserDefaults: FlagValueSource {

    public var name: String {
        return "UserDefaults\(self == UserDefaults.standard ? ".standard" : "")"
    }

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {

        // get the NSObject for the specified key and translate it into a `BoxedFlagValue`
        guard
            let object = self.object(forKey: key),
            let boxed = BoxedFlagValue(object: object, typeHint: Value.self)
        else { return nil }

        return Value(boxedFlagValue: boxed)
    }

    public func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        guard let value = value else {
            self.removeObject(forKey: key)
            return
        }

        // get the `NSObject` from the `BoxedFlagValue` and set it in the user defaults
        self.set(value.boxedFlagValue.object, forKey: key)

    }

    public var valuesDidChange: AnyPublisher<Void, Never>? {
        return NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
```

## Working with generic sources

The `BoxedFlagValue` alone is all you need if you're wrapping a key-value store that uses a concrete type, or something you can cast in the right types. But that doesn't help us at all if your provider also supports generics as we have no way for the compiler to infer that `Value`, which must conform to `FlagValue`, also conforms to `MyFlagProviderValue`.

To work around this limitation, Vexil's `FlagValue` provides an associated type that describes the type stored inside the boxed value: `BoxedValueType`.

Let's say we working with Awesome Flag Provider™, and they provided an interface that looked like this:

```swift
protocol AwesomeFlagType {}
extension Bool: AwesomeFlagType {}		// plus other types

class AwesomeFlagProvider {

    func get<Value> (key: String) -> Value? where Value: AwesomeFlagType {
        // some awesome logic
        return nil
    }

    func set<Value> (_ value: Value, key: String) where Value: AwesomeFlagType {
        // more awesome logic
    }

}
```

If we were to attempt to use `get(key:)` directly we'd get an error:

```swift
extension AwesomeFlagProvider: FlagValueSource {
    var name: String { "My Awesome Flag Provider" }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        return self.get(key: key)		// ERROR! Instance method 'get(key:)' requires that 'Value' conform to 'AwesomeFlagType'
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
    }
}
```

And there is no real way with the current generics implementations for us to make them conform:

```
// ERROR! Type 'AwesomeFlagProvider' does not conform to protocol 'FlagValueSource'
func flagValue<Value>(key: String) -> Value? where Value: FlagValue & AwesomeFlagType {
    return self.get(key: key)
}
```

But since a `FlagValue` can be anything, you use the `FlagValue`'s `BoxedValueType`:

```swift
func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
    if Value.BoxedValueType.self == Bool.self || Value.BoxedValueType.self == Bool?.self {
        let value: Bool? = self.get(key: key)
        return value as? Value
    }

    // support for other types

    return nil
}
```

To be honest, this feels quite horrible but seems to be the only way to make the compiler happy. `FlagValue.BoxedValueType` is provided solely so the possible types you need to check for is more limited than _everything_.

[defining]: Defining-Flags.md