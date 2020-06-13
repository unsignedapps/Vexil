//
//  TestHelpers.swift
//  Vexil
//
//  Created by Rob Amos on 7/6/20.
//

import XCTest

public func AssertNoThrow (file: StaticString = #file, line: UInt = #line, _ expression: () throws -> ()) {
    XCTAssertNoThrow(try expression(), file: file, line: line)
}

public func AssertThrows<E> (error: E, file: StaticString = #file, line: UInt = #line, _ expression: () throws -> ()) where E: Equatable {
    var result: E?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError as? E
    }
    XCTAssertEqual(result, error)
}

@discardableResult
public func AssertThrows (file: StaticString = #file, line: UInt = #line, _ expression: () throws -> ()) -> Swift.Error? {
    var result: Swift.Error?
    XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError in
        result = thrownError
    }
    return result
}

