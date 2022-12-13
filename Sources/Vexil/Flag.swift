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

    // FlagContainers may have many flags, so to reduce code bloat
    // it's important that each Flag have as few stored properties
    // (with nontrivial copy behavior) as possible. We therefore use
    // a single `Allocation` for all of Flag's stored properties.
    final class Allocation {
        var id: UUID
        var info: FlagInfo
        var defaultValue: Value

        // these are computed lazily during `decorate`
        var key: String?
        weak var lookup: Lookup?

        var codingKeyStrategy: CodingKeyStrategy

        init(
            id: UUID = UUID(),
            info: FlagInfo,
            defaultValue: Value,
            key: String? = nil,
            lookup: Lookup? = nil,
            codingKeyStrategy: CodingKeyStrategy
        ) {
            self.id = id
            self.info = info
            self.defaultValue = defaultValue
            self.key = key
            self.lookup = lookup
            self.codingKeyStrategy = codingKeyStrategy
        }

        func copy() -> Allocation {
            Allocation(
                id: id,
                info: info,
                defaultValue: defaultValue,
                key: key,
                lookup: lookup,
                codingKeyStrategy: codingKeyStrategy
            )
        }
    }

    // MARK: - Properties

    var allocation: Allocation

    /// All `Flag`s are `Identifiable`
    public var id: UUID {
        get {
            allocation.id
        }
        set {
            if !isKnownUniquelyReferenced(&allocation) {
                allocation = allocation.copy()
            }
            allocation.id = newValue
        }
    }

    /// A collection of information about this `Flag`, such as its display name and description.
    public var info: FlagInfo {
        get {
            allocation.info
        }
        set {
            if !isKnownUniquelyReferenced(&allocation) {
                allocation = allocation.copy()
            }
            allocation.info = newValue
        }
    }

    /// The default value for this `Flag` for when no sources are available, or if no
    /// sources have a value specified for this flag.
    public var defaultValue: Value {
        get {
            allocation.defaultValue
        }
        set {
            if !isKnownUniquelyReferenced(&allocation) {
                allocation = allocation.copy()
            }
            allocation.defaultValue = newValue
        }
    }

    /// The `Flag` value. This is a calculated property based on the `FlagPole`s sources.
    public var wrappedValue: Value {
        return value(in: nil)?.value ?? self.defaultValue
    }

    /// The string-based Key for this `Flag`, as calculated during `init`. This key is
    /// sent to  the `FlagValueSource`s.
    public var key: String {
        return self.allocation.key!
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
        self.init(
            wrappedValue: initialValue,
            name: name,
            codingKeyStrategy: codingKeyStrategy,
            description: description
        )
    }

    /// Initialises a new `Flag` with the supplied info.
    ///
    /// You must at least a `description` of the flag and specify the default value
    ///
    /// ```swift
    /// @Flag(description: "This is a test flag. Isn't it nice?")
    /// var myFlag: Bool = false
    /// ```
    ///
    /// - Parameters:
    ///   - name:               An optional display name to give the flag. Only visible in flag editors like Vexillographer. Default is to calculate one based on the property name.
    ///   - codingKeyStrategy:  An optional strategy to use when calculating the key name. The default is to use the `FlagPole`s strategy.
    ///   - description:        A description of this flag. Used in flag editors like Vexillographer, and also for future developer context.
    ///                         You can also specify `.hidden` to hide this flag from Vexillographer.
    ///
    public init (wrappedValue: Value, name: String? = nil, codingKeyStrategy: CodingKeyStrategy = .default, description: FlagInfo) {
        var info = description
        info.name = name
        self.allocation = Allocation(
            info: info,
            defaultValue: wrappedValue,
            codingKeyStrategy: codingKeyStrategy
        )
    }


    // MARK: - Decorated Conformance

    /// Decorates the receiver with the given lookup info.
    ///
    /// `self.key` is calculated during this step based on the supplied parameters. `lookup` is used by `self.wrappedValue`
    /// to find out the current flag value from the source hierarchy.
    ///
    internal func decorate (
        lookup: Lookup,
        label: String,
        codingPath: [String],
        config: VexilConfiguration
    ) {
        // FIXME: this doesn't use `isKnownUniquelyReferenced`, but perhaps it should?
        self.allocation.lookup = lookup

        var action = self.allocation.codingKeyStrategy.codingKey(label: label)
        if action == .default {
            action = config.codingPathStrategy.codingKey(label: label)
        }

        switch action {

        case .append(let string):
            // FIXME: for compatibility with existing behavior, this doesn't use `isKnownUniquelyReferenced`, but perhaps it should?
            self.allocation.key = (codingPath + [string])
                .joined(separator: config.separator)

        case .absolute(let string):
            // FIXME: for compatibility with existing behavior, this doesn't use `isKnownUniquelyReferenced`, but perhaps it should?
            self.allocation.key = string

        // these two options should really never happen, but just in case, use what we've got
        case .default, .skip:
            assertionFailure("Invalid `CodingKeyAction` found when attempting to create key name for Flag \(self)")
            // FIXME: for compatibility with existing behavior, this doesn't use `isKnownUniquelyReferenced`, but perhaps it should?
            self.allocation.key = (codingPath + [label])
                .joined(separator: config.separator)

        }
    }


    // MARK: - Lookup Support

    func value (in source: FlagValueSource?) -> LookupResult<Value>? {
        guard let lookup = self.allocation.lookup, let key = self.allocation.key else {
            return LookupResult(source: nil, value: self.defaultValue)
        }
        let value: LookupResult<Value>? = lookup.lookup(key: key, in: source)

        // if we're looking up against a specific source we return only what we get from it
        if source != nil {
            return value
        }

        // otherwise we're looking up on the FlagPole - which must always return a value so go back to our default
        return value ?? LookupResult(source: nil, value: self.defaultValue)
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
        allocation.lookup!.publisher(key: self.key)
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
        allocation.lookup!.publisher(key: self.key)
    }

}

#endif
