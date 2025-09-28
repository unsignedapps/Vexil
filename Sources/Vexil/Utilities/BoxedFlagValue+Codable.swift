//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation

extension BoxedFlagValue: Encodable {

    enum TypeKeys: String, CodingKey {
        case array = "a"
        case bool = "b"
        case data = "d"
        case dictionary = "o"
        case double = "r"
        case float = "f"
        case integer = "i"
        case none = "n"
        case string = "s"
    }

    public func encode(to encoder: Encoder) throws {
        switch self {

        // Simple Types
        case let .bool(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .bool)

        case let .data(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .data)

        case let .double(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .double)

        case let .float(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .float)

        case let .integer(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .integer)

        case .none:
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encodeNil(forKey: .none)

        case let .string(value):
            var container = encoder.container(keyedBy: TypeKeys.self)
            try container.encode(value, forKey: .string)

        // Collection Types
        case let .array(array):
            var wrapper = encoder.container(keyedBy: TypeKeys.self)
            var container = wrapper.nestedUnkeyedContainer(forKey: .array)
            for value in array {
                try container.encode(value)
            }

        case let .dictionary(dictionary):
            var wrapper = encoder.container(keyedBy: TypeKeys.self)
            var container = wrapper.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .dictionary)
            for pair in dictionary {
                try container.encode(pair.value, forKey: DynamicCodingKey(pair.key))
            }
        }
    }

}


// MARK: - Decodable Support

extension BoxedFlagValue: Decodable {

    // swiftlint:disable:next cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeKeys.self)

        // Simple Types
        if container.contains(.bool) {
            self = try .bool(container.decode(Bool.self, forKey: .bool))

        } else if container.contains(.data) {
            self = try .data(container.decode(Data.self, forKey: .data))

        } else if container.contains(.double) {
            self = try .double(container.decode(Double.self, forKey: .double))

        } else if container.contains(.float) {
            self = try .float(container.decode(Float.self, forKey: .float))

        } else if container.contains(.integer) {
            self = try .integer(container.decode(Int.self, forKey: .integer))

        } else if container.contains(.none) {
            self = .none

        } else if container.contains(.string) {
            self = try .string(container.decode(String.self, forKey: .string))

            // Collection Types
        } else if container.contains(.array) {
            var array = [BoxedFlagValue]()
            var nested = try container.nestedUnkeyedContainer(forKey: .array)
            while nested.isAtEnd == false {
                try array.append(nested.decode(BoxedFlagValue.self))
            }
            self = .array(array)

        } else if container.contains(.dictionary) {
            var dict = [String: BoxedFlagValue]()
            let nested = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .dictionary)
            for key in nested.allKeys {
                dict[key.stringValue] = try nested.decode(BoxedFlagValue.self, forKey: key)
            }
            self = .dictionary(dict)

        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type when decoding a BoxedFlagValue")
            )
        }

    }

}


// MARK: - Dynamic Coding Keys

private struct DynamicCodingKey: CodingKey, ExpressibleByStringLiteral {

    var stringValue: String
    var intValue: Int?

    init(_ value: String) {
        self.stringValue = value
        self.intValue = nil
    }

    init(stringLiteral value: StringLiteralType) {
        self.stringValue = value
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = intValue.description
    }

}
