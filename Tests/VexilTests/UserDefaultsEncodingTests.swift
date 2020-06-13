//
//  UserDefaultsEncodingTests.swift
//  Vexil
//
//  Created by Rob Amos on 6/6/20.
//

@testable import Vexil
import XCTest

final class UserDefaultsEncodingTests: XCTestCase {

    // MARK: - Fixtures

    private var defaults: UserDefaults!

    override func setUp () {
        super.setUp()
        self.defaults = UserDefaults(suiteName: "UserDefaultsEncodingTests")
    }

    override func tearDown () {
        super.tearDown()
        self.defaults.removePersistentDomain(forName: "UserDefaultsEncodingTests")
    }


    // MARK: - Removing Values

    func testEncodeMissingUnset () {
        AssertNoThrow {
            self.defaults.set(true, forKey: #function)
            XCTAssertNotNil(self.defaults.object(forKey: #function))

            try self.defaults.setFlagValue(Optional<Bool>.none, key: #function)         // swiftlint:disable:this syntactic_sugar
            XCTAssertNil(self.defaults.object(forKey: #function))
        }
    }


    // MARK: - Decoding Boolean Types

    func testEncodeBooleanTrue () {
        AssertNoThrow {
            let value = true

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.bool(forKey: #function), value)
        }
    }

    func testEncodeBooleanFalse () {
        AssertNoThrow {
            let value = false

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.bool(forKey: #function), value)
        }
    }


    // MARK: - Decoding String Types

    func testEncodeString () {
        AssertNoThrow {
            let value = "abcd1234"

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.string(forKey: #function), value)
        }
    }

    func testEncodeURL () {
        AssertNoThrow {
            let value = URL(string: "https://google.com/")!

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.url(forKey: #function), value)
        }
    }


    // MARK: - Encoding Float / Double Types

    func testEncodeDouble () {
        AssertNoThrow {
            let value = Double(1.23456789)

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.double(forKey: #function), value, accuracy: 0.00001)
        }
    }

    func testEncodeFloat () {
        AssertNoThrow {
            let value = Float(1.23456789)

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.float(forKey: #function), value, accuracy: 0.00001)
        }
    }


    // MARK: - Encoding Integer Types

    func testEncodeInt () {
        AssertNoThrow {
            let value = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.integer(forKey: #function), value)
        }
    }

    func testEncodeInt8 () {
        AssertNoThrow {
            let value: Int8 = 12

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(Int8(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeInt16 () {
        AssertNoThrow {
            let value: Int16 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(Int16(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeInt32 () {
        AssertNoThrow {
            let value: Int32 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(Int32(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeInt64 () {
        AssertNoThrow {
            let value: Int64 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(Int64(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeUInt () {
        AssertNoThrow {
            let value: UInt = 12

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(UInt(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeUInt8 () {
        AssertNoThrow {
            let value: UInt8 = 14

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(UInt8(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeUInt16 () {
        AssertNoThrow {
            let value: UInt16 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(UInt16(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeUInt32 () {
        AssertNoThrow {
            let value: UInt32 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(UInt32(self.defaults.integer(forKey: #function)), value)
        }
    }

    func testEncodeUInt64 () {
        AssertNoThrow {
            let value: UInt64 = 1234

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(UInt64(self.defaults.integer(forKey: #function)), value)
        }
    }


    // MARK: - Array Tests

    func testEncodeStringArray () {
        AssertNoThrow {
            let value = [ "abc", "123" ]

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.stringArray(forKey: #function), value)
        }
    }

    func testEncodeIntegerArray () {
        AssertNoThrow {
            let value = [ 234, -123 ]

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.array(forKey: #function) as? [Int], value)
        }
    }


    // MARK: - Dictionary Tests

    func testEncodeStringDictionary () {
        AssertNoThrow {
            let value = [
                "key1": "value1",
                "key2": "value2"
            ]

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.dictionary(forKey: #function) as? [String: String], value)
        }
    }

    func testEncodeIntegerDictionary () {
        AssertNoThrow {
            let value = [
                "key1": 123,
                "key2": -987
            ]

            try self.defaults.setFlagValue(value, key: #function)
            XCTAssertEqual(self.defaults.dictionary(forKey: #function) as? [String: Int], value)
        }
    }

    // MARK: - Codable Tests

    func testEncodeCodable () {
        struct MyStruct: FlagValue, Equatable {
            let property1 = "value1"
            let property2 = 123
            let property3 = "🤯"
        }

        let input = MyStruct()

        // manually encoding into json
        let expected = Data(#"{"property1":"value1","property2":123,"property3":"🤯"}"#.utf8)

        AssertNoThrow {
            try self.defaults.setFlagValue(input, key: #function)
            XCTAssertEqual(self.defaults.data(forKey: #function), expected)
        }
    }

}
