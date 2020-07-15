//
//  FlagValue.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

// swiftlint:disable extension_access_modifier

import Foundation

public protocol FlagValue: Codable {
    init? (boxedFlagValue: BoxedFlagValue)

    var boxedFlagValue: BoxedFlagValue { get }
}

public protocol FlagDisplayValue: FlagValue {
    var flagDisplayValue: String { get }
}

// MARK: - Boxed Flag Values

/// An intermediate type used to make encoding and decoding of types simpler for `FlagValueSource`s
///
public enum BoxedFlagValue {
    case bool(Bool)
    case string(String)
    case data(Data)
    case double(Double)
    case float(Float)
    case integer(Int)
    case array([BoxedFlagValue])
    case dictionary([String: BoxedFlagValue])
}


// MARK: - Conforming Simple Types

extension Bool: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .bool(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .bool(self)
    }
}

extension String: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .string(self)
    }
}

extension URL: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .string(let value) = boxedFlagValue else { return nil }
        self.init(string: value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .string(self.absoluteString)
    }
}

extension Date: FlagValue {
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
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .data(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .data(self)
    }
}

extension Double: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .double(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .double(self)
    }
}

extension Float: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        switch boxedFlagValue {
        case let .float(value):         self = value
        case let .double(value):        self = Float(value)
        default:                        return nil
        }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .float(self)
    }
}

extension Int: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = value
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(self)
    }
}

extension Int8: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = Int8(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int16: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = Int16(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int32: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = Int32(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension Int64: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = Int64(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = UInt(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt8: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = UInt8(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt16: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = UInt16(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt32: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = UInt32(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}

extension UInt64: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .integer(let value) = boxedFlagValue else { return nil }
        self = UInt64(value)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .integer(Int(self))
    }
}


// MARK: - Conforming Other Types

extension RawRepresentable where Self: FlagValue, RawValue: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard let rawValue = RawValue(boxedFlagValue: boxedFlagValue) else { return nil }
        self.init(rawValue: rawValue)
    }

    public var boxedFlagValue: BoxedFlagValue {
        return self.rawValue.boxedFlagValue
    }
}

extension Array: FlagValue where Element: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .array(let array) = boxedFlagValue else { return nil }
        self = array.compactMap { Element(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .array(self.map({ $0.boxedFlagValue }))
    }
}

extension Dictionary: FlagValue where Key == String, Value: FlagValue {
    public init? (boxedFlagValue: BoxedFlagValue) {
        guard case .dictionary(let dictionary) = boxedFlagValue else { return nil }
        self = dictionary.compactMapValues { Value(boxedFlagValue: $0) }
    }

    public var boxedFlagValue: BoxedFlagValue {
        return .dictionary(self.mapValues({ $0.boxedFlagValue }))
    }
}


// MARK: - Conforming Codable Types

extension Decodable where Self: FlagValue {
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

extension Encodable where Self: FlagValue {
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
private struct Wrapper<Wrapped>: Codable where Wrapped: Codable {
    var wrapped: Wrapped
}
