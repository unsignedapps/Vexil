//
//  Flag.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

#if !os(Linux)
import Combine
#endif

import Foundation

/// A wrapper representing a Feature Flag / Feature Toggle.
///
/// All `Flag`s must be initialised with a default value and a description.
/// The default value is used when none of the sources on the `FlagPole`
/// have a value specified for this flag. The description is used for future
/// developer reference and in Vexlliographer to describe the flag.
///
/// The type that you wrap with `@Flag` must conform to `FlagValue`.
///
/// The wrapper returns itself as its `projectedValue` property in case
/// you need to acess any information about the flag itself.
///
/// Note that `Flag`s are immutable. If you need to mutate this flag use a `Snapshot`.
///
@propertyWrapper
public struct Flag<Value>: Decorated, Identifiable where Value: FlagValue {

    // MARK: - Properties

    /// All `Flag`s are `Identifiable`
    public var id = UUID()

    /// A collection of information about this `Flag`, such as its display name and description.
    public var info: FlagInfo

    /// The default value for this `Flag` for when no sources are available, or if no
    /// sources have a value specified for this flag.
    public var defaultValue: Value

    /// The `Flag` value. This is a calculated property based on the `FlagPole`s sources.
    public var wrappedValue: Value {
        guard let lookup = self.decorator.lookup, let key = self.decorator.key else { return self.defaultValue }
        return lookup.lookup(key: key) ?? self.defaultValue
    }

    /// The string-based Key for this `Flag`, as calculated during `init`. This key is
    /// sent to  the `FlagValueSource`s.
    public var key: String {
        return self.decorator.key!
    }

    /// A reference to the `Flag` itself is available as a projected value, in case you need
    /// access to the key or other information.
    public var projectedValue: Flag<Value> {
        return self
    }


    // MARK: - Initialisation

    /// Initialises a new `Flag` with the supplied info.
    ///
    /// You must at least provide a `default` value and `description` of the flag:
    ///
    /// ```swift
    /// @Flag(default: false, description: "This is a test flag. Isn't it nice?")
    /// var myFlag: Bool
    /// ```
    ///
    /// - Parameters:
    ///   - name:               An optional display name to give the flag. Only visible in flag editors like Vexillographer. Default is to calculate one based on the property name.
    ///   - codingKeyStrategy:  An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
    ///   - default:            The default value for this `Flag` should no sources have it set.
    ///   - description:        A description of this flag. Used in flag editors like Vexillographer, and also for future developer context.
    ///                         You can also specify `.hidden` to hide this flag from Vexillographer.
    ///
    public init (name: String? = nil, codingKeyStrategy: CodingKeyStrategy = .default, default initialValue: Value, description: FlagInfo) {
        self.codingKeyStrategy = codingKeyStrategy
        self.defaultValue = initialValue

        var info = description
        info.name = name
        self.info = info
    }


    // MARK: - Decorated Conformance

    internal var decorator = Decorator()
    internal let codingKeyStrategy: CodingKeyStrategy

    /// Decorates the receiver with the given lookup info.
    ///
    /// `self.key` is calculated during this step based on the supplied parameters. `lookup` is used by `self.wrappedValue`
    /// to find out the current flag value from the source hierarchy.
    ///
    internal func decorate (lookup: Lookup, label: String, codingPath: [String], config: VexilConfiguration) {
        self.decorator.lookup = lookup

        var action = self.codingKeyStrategy.codingKey(label: label)
        if action == .default {
            action = config.codingPathStrategy.codingKey(label: label)
        }

        switch action {

        case .append(let string):
            self.decorator.key = (codingPath + [string])
                .joined(separator: config.separator)

        case .absolute(let string):
            self.decorator.key = string

        // these two options should really never happen, but just in case, use what we've got
        case .default, .skip:
            assertionFailure("Invalid `CodingKeyAction` found when attempting to create key name for Flag \(self)")
            self.decorator.key = (codingPath + [label])
                .joined(separator: config.separator)

        }
    }
}


// MARK: - Equatable and Hashable Support

extension Flag: Equatable where Value: Equatable {
    public static func == (lhs: Flag, rhs: Flag) -> Bool {
        return lhs.key == rhs.key && lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Flag: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
        hasher.combine(self.wrappedValue)
    }
}


// MARK: - Debugging

extension Flag: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(key)=\(wrappedValue)"
    }
}


// MARK: - Real Time Flag Publishing

#if !os(Linux)

public extension Flag where Value: FlagValue & Equatable {

    /// A `Publisher` that provides real-time updates if any flag value changes.
    ///
    /// This is essentially a filter on the `FlagPole`s Publisher.
    ///
    /// As your `FlagValue` is also `Equatable`, this publisher will automatically
    /// remove duplicates.
    ///
    var publisher: AnyPublisher<Value, Never> {
        decorator.lookup!.publisher(key: self.key)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}

public extension Flag {

    /// A `Publisher` that provides real-time updates if any time the source
    /// hierarchy changes.
    ///
    /// This is essentially a filter on the `FlagPole`s Publisher.
    ///
    /// As your `FlagValue` is not `Equatable`, this publisher will **not**
    /// remove duplicates.
    ///
    var publisher: AnyPublisher<Value, Never> {
        decorator.lookup!.publisher(key: self.key)
    }

}

#endif
