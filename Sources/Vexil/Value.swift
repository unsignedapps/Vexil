//
//  FlagValue.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

// swiftlint:disable extension_access_modifier

import Foundation

/// A type that represents the wrapped value of a `Flag`
///
/// This type exists solely so we can provide hints for boxing/unboxing or encoding/decoding
/// into various `FlagValueSource`s.
///
/// See the full documentation for information and examples on using custom types
/// with Vexil.
///
public protocol FlagValue {

    /// The type that this `FlagValue` would be boxed into.
    /// Used by `FlagValueSource`s to provide interop with different providers
    ///
    /// For `Codable` support, a default boxed type of `Data` is assumed if you
    /// do not specify one directly.
    ///
    associatedtype BoxedValueType = Data

    /// When initialised with a BoxedFlagValue your conforming type must
    /// be able to unbox and initialise itself. Return nil if you cannot successfully
    /// unbox the flag value, or if it is an incompatible type.
    ///
    init? (boxedFlagValue: BoxedFlagValue)

    /// Your conforming type must return an instance of the BoxedFlagValue
    /// with the boxed type included. This type should match the type
    /// specified in the `BoxedValueType` assocaited type.
    ///
    var boxedFlagValue: BoxedFlagValue { get }
}

/// A convenience protocol used by flag editors like Vexillographer.
///
/// Use this with your `CaseIterable` types when you want to customise
/// the value displayed in the UI.
///
/// - Note: This is only used by types that are edited with a `Picker` (eg. those
/// that are `CaseIterable`. It is not used by types that are edited
/// with a `TextField` or `Toggle`.
///
public protocol FlagDisplayValue {

    /// The value to display in the `Picker` for a given flag value
    var flagDisplayValue: String { get }
}

// MARK: - Boxed Flag Values

/// An intermediate type used to make encoding and decoding of types simpler for `FlagValueSource`s
///
/// Any custom type you conform to `FlagValue` must be able to be represented using one of these types
///
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


// MARK: - Conforming Simple Types

extension Bool: FlagValue {
    public typealias BoxedValueType = Bool

    public init? (boxedFlagValue: BoxedFlagValue) {
        switch boxedFlagValue {
        case let .bool(value):          self = value
        case let .integer(value):       self = value != 0
        case let .float(value):         self = value != 0.0
        case let .double(value):        self = value != 0.0
        case let .string(value):        self = (value as NSString).boolValue
        default:                        return nil
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .bool(self)
    }
}

extension String: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .string(self)
    }
}

extension URL: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }
        self.init(string: value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .string(self.absoluteString)
    }
}

extension Date: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }

        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else { return nil }

        self = date
    }

    public var boxedFlagValue: BoxedFlagValue {
        let formatter = ISO8601DateFormatter()
        return .string(formatter.string(from: self))
    }
}

extension Data: FlagValue {
    public typealias BoxedValueType = Data

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .data(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .data(self)
    }
}

extension Double: FlagValue {
    public typealias BoxedValueType = Double

    public init? (boxedFlagValue: BoxedFlagValue) {
        switch boxedFlagValue {
        case let .double(value):            self = value
        case let .float(value):             self = Double(value)
        case let .integer(value):           self = Double(value)
        case let .string(value):            self = (value as NSString).doubleValue
        default:                            return nil
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .double(self)
    }
}

extension Float: FlagValue {
    public typealias BoxedValueType = Float

    public init? (boxedFlagValue: BoxedFlagValue) {
        switch boxedFlagValue {
        case let .float(value):             self = value
        case let .double(value):            self = Float(value)
        case let .integer(value):           self = Float(value)
        case let .string(value):            self = (value as NSString).floatValue
        default:                            return nil
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .float(self)
    }
}

extension Int: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        switch boxedFlagValue {
        case let .integer(value):           self = value
        case let .string(value):            self = (value as NSString).integerValue
        default:                            return nil
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(self)
    }
}

extension Int8: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(Int8.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int16: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(Int16.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int32: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(Int32.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int64: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(Int64.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(UInt.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt8: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(UInt8.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt16: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(UInt16.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt32: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(UInt32.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt64: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue).flatMap(UInt64.init(exactly:)) else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}


// MARK: - Conforming Other Types

extension RawRepresentable where Self: FlagValue, RawValue: FlagValue {
    public typealias BoxedValueType = RawValue.BoxedValueType

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let rawValue = RawValue(boxedFlagValue: boxedFlagValue) else { return nil }
        self.init(rawValue: rawValue)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return self.rawValue.boxedFlagValue
    }
}

extension Optional: FlagValue where Wrapped: FlagValue {
    public typealias BoxedValueType = Wrapped.BoxedValueType?

    public init? (boxedFlagValue: BoxedFlagValue) {
        if case .none = boxedFlagValue {
            self = .none

        } else if let wrapped = Wrapped(boxedFlagValue: boxedFlagValue) {
            self = wrapped

        } else {
            self = .none
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return self?.boxedFlagValue ?? .none
    }
}

extension Array: FlagValue where Element: FlagValue {
    public typealias BoxedValueType = [Element.BoxedValueType]

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .array(let array) = boxedFlagValue else { return nil }
        self = array.compactMap { Element(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .array(self.map({ $0.boxedFlagValue }))
    }
}

extension Dictionary: FlagValue where Key == String, Value: FlagValue {
    public typealias BoxedValueType = [String: Value.BoxedValueType]

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .dictionary(let dictionary) = boxedFlagValue else { return nil }
        self = dictionary.compactMapValues { Value(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .dictionary(self.mapValues({ $0.boxedFlagValue }))
    }
}


// MARK: - Conforming Codable Types

extension Decodable where Self: FlagValue, Self: Encodable {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .data(let data) = boxedFlagValue else { return nil }

        do {
            let decoder = JSONDecoder()
            self = try decoder.decode(Wrapper<Self>.self, from: data).wrapped

        } catch {
            assertionFailure("[Vexil] Unable to decode type \(String(describing: Self.self)): \(error))")
            return nil
        }
    }
}

extension Encodable where Self: FlagValue, Self: Decodable {
    public var boxedFlagValue: BoxedFlagValue {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return .data(try encoder.encode(Wrapper(wrapped: self)))

        } catch {
            assertionFailure("[Vexil] Unable to encode type \(String(describing: Self.self)): \(error)")
            return .data(Data())
        }
    }
}

// Because we can't encode/decode a JSON fragment in Swift 5.2 on Linux we wrap it in this.
internal struct Wrapper<Wrapped>: Codable where Wrapped: Codable {
    var wrapped: Wrapped
}
