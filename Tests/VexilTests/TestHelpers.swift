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

import XCTest

#if compiler(>=5.3)

public func AssertNoThrow(file: StaticString = #filePath, line: UInt = #line, _ expression: () throws -> Void) {
    XCTAssertNoThrow(try expression(), file: file, line: line)
}

public func AssertThrows<E>(error: E, file: StaticString = #filePath, line: UInt = #line, _ expression: () throws -> Void) where E: Equatable {
    var result: E?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError as? E
    }
    XCTAssertEqual(result, error)
}

@discardableResult
public func AssertThrows(file: StaticString = #filePath, line: UInt = #line, _ expression: () throws -> Void) -> Swift.Error? {
    var result: Swift.Error?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError
    }
    return result
}

#else

public func AssertNoThrow(file: StaticString = #file, line: UInt = #line, _ expression: () throws -> Void) {
    XCTAssertNoThrow(try expression(), file: file, line: line)
}

public func AssertThrows<E>(error: E, file: StaticString = #file, line: UInt = #line, _ expression: () throws -> Void) where E: Equatable {
    var result: E?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError as? E
    }
    XCTAssertEqual(result, error)
}

@discardableResult
public func AssertThrows(file: StaticString = #file, line: UInt = #line, _ expression: () throws -> Void) -> Swift.Error? {
    var result: Swift.Error?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError
    }
    return result
}

#endif

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard index < endIndex else {
            return nil
        }
        return self[index]
    }
}
