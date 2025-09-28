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

#if !os(Linux)

import Foundation
import Testing
@testable import Vexil

@Suite("UserDefaults Decoding", .tags(.userDefaults))
final class UserDefaultsDecodingTests {

    // MARK: - Decoding Missing Values

    @Test("Decodes missing value as nil")
    func missing() {
        withUserDefaults(#function) { defaults in
            #expect(defaults.flagValue(key: "test") as Bool? == nil)
        }
    }

    @Test("Decodes unset value as nil")
    func unset() {
        withUserDefaults(#function) { defaults in
            defaults.set(true, forKey: "test")
            defaults.removeObject(forKey: "test")
            #expect(defaults.flagValue(key: "test") as Bool? == nil)
        }
    }


    // MARK: - Decoding Boolean Types

    @Test("Decodes boolean true")
    func booleanTrue() {
        withUserDefaults(#function) { defaults in
            defaults.set(true, forKey: "test")
            #expect(defaults.flagValue(key: "test") == true)
        }
    }

    @Test("Decodes boolean false")
    func booleanFalse() {
        withUserDefaults(#function) { defaults in
            defaults.set(false, forKey: "test")
            #expect(defaults.flagValue(key: "test") == false)
        }
    }

    @Test("Decodes integer as boolean")
    func booleanInteger() {
        withUserDefaults(#function) { defaults in
            defaults.set(1, forKey: "test")
            #expect(defaults.flagValue(key: "test") == true)
        }
    }

    @Test("Decodes double as boolean")
    func booleanDouble() {
        withUserDefaults(#function) { defaults in
            defaults.set(1.0, forKey: "test")
            #expect(defaults.flagValue(key: "test") == true)
        }
    }

    @Test("Decodes string as boolean")
    func booleanString() {
        withUserDefaults(#function) { defaults in
            defaults.set("t", forKey: "test")
            #expect(defaults.flagValue(key: "test") == true)
        }
    }


    // MARK: - Decoding String Types

    @Test("Decodes string")
    func string() {
        withUserDefaults(#function) { defaults in
            defaults.set("abcd1234", forKey: "test")
            #expect(defaults.flagValue(key: "test") == "abcd1234")
        }
    }

    @Test("Decodes URL")
    func url() {
        withUserDefaults(#function) { defaults in
            defaults.set("https://google.com/", forKey: "test")
            #expect(defaults.flagValue(key: "test") == URL(string: "https://google.com/")!)
        }
    }


    // MARK: - Decoding Float / Double Types

    @Test("Decodes double")
    func double() {
        withUserDefaults(#function) { defaults in
            defaults.set(123.456, forKey: "test")
            #expect(defaults.flagValue(key: "test") == 123.456)
        }
    }

    @Test("Decodes float")
    func float() {
        withUserDefaults(#function) { defaults in
            defaults.set(Float(123.456), forKey: "test")
            #expect(defaults.flagValue(key: "test") == Float(123.456))
        }
    }

    @Test("Decodes integer as double")
    func doubleinteger() {
        withUserDefaults(#function) { defaults in
            defaults.set(1, forKey: "test")
            #expect(defaults.flagValue(key: "test") == 1.0)
        }
    }

    @Test("Decodes string as double")
    func doubleString() {
        withUserDefaults(#function) { defaults in
            defaults.set("1.23456789", forKey: "test")
            #expect(defaults.flagValue(key: "test") == 1.23456789)
        }
    }


    // MARK: - Decoding Integer Types

    @Test("Decodes integer")
    func int() {
        withUserDefaults(#function) { defaults in
            defaults.set(1234, forKey: "test")
            #expect(defaults.flagValue(key: "test") == 1234)
        }
    }

    @Test("Decodes 8-bit integer")
    func int8() {
        withUserDefaults(#function) { defaults in
            defaults.set(Int8(12), forKey: "test")
            #expect(defaults.flagValue(key: "test") == Int8(12))
        }
    }

    @Test("Decodes 16-bit integer")
    func int16() {
        withUserDefaults(#function) { defaults in
            defaults.set(Int16(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == Int16(1234))
        }
    }

    @Test("Decodes 32-bit integer")
    func int32() {
        withUserDefaults(#function) { defaults in
            defaults.set(Int32(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == Int32(1234))
        }
    }

    @Test("Decodes 64-bit integer")
    func int64() {
        withUserDefaults(#function) { defaults in
            defaults.set(Int64(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == Int64(1234))
        }
    }

    @Test("Decodes unsigned integer")
    func uint() {
        withUserDefaults(#function) { defaults in
            defaults.set(UInt(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt(1234))
        }
    }

    @Test("Decodes 8-bit unsigned integer")
    func uint8() {
        withUserDefaults(#function) { defaults in
            defaults.set(UInt8(12), forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt8(12))
        }
    }

    @Test("Decodes 16-bit unsigned integer")
    func uint16() {
        withUserDefaults(#function) { defaults in
            defaults.set(UInt16(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt16(1234))
        }
    }

    @Test("Decodes 32-bit unsigned integer")
    func uint32() {
        withUserDefaults(#function) { defaults in
            defaults.set(UInt32(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt32(1234))
        }
    }

    @Test("Decodes 64-bit unsigned integer")
    func uint64() {
        withUserDefaults(#function) { defaults in
            defaults.set(UInt64(1234), forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt64(1234))
        }
    }

    @Test("Decodes string as integer")
    func intString() {
        withUserDefaults(#function) { defaults in
            defaults.set("1234", forKey: "test")
            #expect(defaults.flagValue(key: "test") == 1234)
        }
    }

    @Test("Decodes string as unsigned integer")
    func uintString() {
        withUserDefaults(#function) { defaults in
            defaults.set("1234", forKey: "test")
            #expect(defaults.flagValue(key: "test") == UInt(1234))
        }
    }


    // MARK: - Wrapping Types

    @Test("Decodes raw representable string")
    func rawRepresentableString() {
        withUserDefaults(#function) { defaults in
            defaults.set("Test Value", forKey: "test")
            #expect(defaults.flagValue(key: "test") == TestStruct(rawValue: "Test Value"))

            struct TestStruct: RawRepresentable, FlagValue, Equatable {
                var rawValue: String
            }
        }
    }

    @Test("Decodes raw representable boolean")
    func rawRepresentableBool() {
        withUserDefaults(#function) { defaults in
            defaults.set(true, forKey: "test")
            #expect(defaults.flagValue(key: "test") == TestStruct(rawValue: true))

            struct TestStruct: RawRepresentable, FlagValue, Equatable {
                var rawValue: Bool
            }
        }
    }

    // double optionals here because flagValue(key:) returns an optional, so Value is inferred as "String?" or "Bool?"

    @Test("Decodes optional boolean")
    func optionalBool() {
        withUserDefaults(#function) { defaults in
            defaults.set(true, forKey: "test")
            #expect(defaults.flagValue(key: "test") == Bool??.some(true))
        }
    }

    @Test("Decodes optional string")
    func optionalString() {
        withUserDefaults(#function) { defaults in
            defaults.set("Test Value", forKey: "test")
            #expect(defaults.flagValue(key: "test") == String??.some("Test Value"))
        }
    }

    @Test("Decodes nil")
    func optionalNil() {
        withUserDefaults(#function) { defaults in
            defaults.removeObject(forKey: "test")
            #expect(defaults.flagValue(key: "test") == String??.none)
        }
    }

    @Test("Decodes string as optional boolean")
    func optionalBoolString() {
        withUserDefaults(#function) { defaults in
            defaults.set("t", forKey: "test")
            defaults.synchronize()
            #expect(defaults.flagValue(key: "test") == Bool??.some(true))
        }
    }

    // MARK: - Array Tests

    @Test("Decodes string array")
    func stringArray() {
        withUserDefaults(#function) { defaults in
            defaults.set([ "abc", "123" ], forKey: "test")
            #expect(defaults.flagValue(key: "test") == [ "abc", "123" ])
        }
    }

    @Test("Decodes integer array")
    func integerArray() {
        withUserDefaults(#function) { defaults in
            defaults.set([ 234, -123 ], forKey: "test")
            #expect(defaults.flagValue(key: "test") == [ 234, -123 ])
        }
    }


    // MARK: - Dictionary Tests

    @Test("Decodes string dictionary")
    func stringDictionary() {
        withUserDefaults(#function) { defaults in
            defaults.set([ "key1": "value1", "key2": "value2" ], forKey: "test")
            #expect(defaults.flagValue(key: "test") == [ "key1": "value1", "key2": "value2" ])
        }
    }

    @Test("Decodes integer dictionary")
    func integerDictionary() {
        withUserDefaults(#function) { defaults in
            defaults.set([ "key1": 123, "key2": -987 ], forKey: "test")
            #expect(defaults.flagValue(key: "test") == [ "key1": 123, "key2": -987 ])
        }
    }


    // MARK: - Codable Tests

    @Test("Decodes codable")
    func codable() {
        struct MyStruct: FlagValue, Codable, Equatable {
            let property1: String
            let property2: Int
            let property3: String

            init() {
                self.property1 = "value1"
                self.property2 = 123
                self.property3 = "🤯"
            }
        }

        let expected = MyStruct()

        // manually encoding into json
        let input =
            """
                {
                    "wrapped": {
                        "property1": "value1",
                        "property2": 123,
                        "property3": "🤯"
                    }
                }
            """

        withUserDefaults(#function) { defaults in
            defaults.set(Data(input.utf8), forKey: "test")
            #expect(defaults.flagValue(key: "test") == expected)
        }
    }

    @Test("Decodes enum")
    func enumeration() throws {
        enum MyEnum: String, FlagValue, Equatable {
            case one
            case two
        }

        try withUserDefaults(#function) { defaults in
            try defaults.setFlagValue(MyEnum.one, key: "test")
            #expect(defaults.flagValue(key: "test") == MyEnum.one)
        }
    }

}

/// Swift Testing runs tests inside a TaskGroup, which means sharing UserDefaults across multiple tests is fraught.
private func withUserDefaults(_ suite: String, _ closure: (UserDefaults) throws -> Void) rethrows {
    let defaults = UserDefaults(suiteName: suite)!
    try closure(defaults)
    defaults.removePersistentDomain(forName: suite)
}

#endif // !os(Linux)
