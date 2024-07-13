//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

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
        .bool(self)
    }
}

extension String: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .string(value) = boxedFlagValue else {
            return nil
        }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        .string(self)
    }
}

extension URL: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .string(value) = boxedFlagValue else {
            return nil
        }
        self.init(string: value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .string(absoluteString)
    }
}

extension Date: FlagValue {
    public typealias BoxedValueType = String

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .string(value) = boxedFlagValue else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
        guard let date = formatter.date(from: value) else {
            return nil
        }

        self = date
    }

    public var boxedFlagValue: BoxedFlagValue {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
        return .string(formatter.string(from: self))
    }
}

extension Data: FlagValue {
    public typealias BoxedValueType = Data

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .data(value) = boxedFlagValue else {
            return nil
        }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        .data(self)
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
        .double(self)
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
        .float(self)
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
        .integer(self)
    }
}

extension Int8: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = Int8(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension Int16: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = Int16(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension Int32: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = Int32(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension Int64: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = Int64(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension UInt: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = UInt(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension UInt8: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = UInt8(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension UInt16: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = UInt16(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension UInt32: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = UInt32(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}

extension UInt64: FlagValue {
    public typealias BoxedValueType = Int

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let value = Int(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self = UInt64(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        .integer(Int(self))
    }
}


// MARK: - Conforming Other Types

public extension RawRepresentable where Self: FlagValue, RawValue: FlagValue {
    typealias BoxedValueType = RawValue.BoxedValueType

    init? (boxedFlagValue: BoxedFlagValue) {
        guard let rawValue = RawValue(boxedFlagValue: boxedFlagValue) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }

    var boxedFlagValue: BoxedFlagValue {
        rawValue.boxedFlagValue
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
        self?.boxedFlagValue ?? .none
    }
}

extension Array: FlagValue where Element: FlagValue {
    public typealias BoxedValueType = [Element.BoxedValueType]

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .array(array) = boxedFlagValue else {
            return nil
        }
        self = array.compactMap { Element(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        .array(map(\.boxedFlagValue))
    }
}

extension Dictionary: FlagValue where Key == String, Value: FlagValue {
    public typealias BoxedValueType = [String: Value.BoxedValueType]

    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .dictionary(dictionary) = boxedFlagValue else {
            return nil
        }
        self = dictionary.compactMapValues { Value(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        .dictionary(mapValues { $0.boxedFlagValue })
    }
}


// MARK: - Conforming Codable Types

public extension Decodable where Self: FlagValue, Self: Encodable {
    init? (boxedFlagValue: BoxedFlagValue) {
        guard case let .data(data) = boxedFlagValue else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            self = try decoder.decode(Wrapper<Self>.self, from: data).wrapped

        } catch {
            assertionFailure("[Vexil] Unable to decode type \(String(describing: Self.self)): \(error))")
            return nil
        }
    }
}

public extension Encodable where Self: FlagValue, Self: Decodable {
    var boxedFlagValue: BoxedFlagValue {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return try .data(encoder.encode(Wrapper(wrapped: self)))

        } catch {
            assertionFailure("[Vexil] Unable to encode type \(String(describing: Self.self)): \(error)")
            return .data(Data())
        }
    }
}

// Because we can't encode/decode a JSON fragment in Swift 5.2 on Linux we wrap it in this.
struct Wrapper<Wrapped>: Codable where Wrapped: Codable {
    var wrapped: Wrapped
}
