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

import Foundation
@testable import Vexil
import XCTest

final class FlagValueDictionaryTests: XCTestCase {

    // MARK: - Reading Values

    func testReadsValues() {
        let source: FlagValueDictionary = [
            "top-level-flag": .bool(true),
        ]

        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
        XCTAssertTrue(flagPole.topLevelFlag)
        XCTAssertFalse(flagPole.oneFlagGroup.secondLevelFlag)
    }


    // MARK: - Writing Values

    func testWritesValues() throws {
        let source = FlagValueDictionary()
        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        let snapshot = flagPole.emptySnapshot()
        snapshot.topLevelFlag = true
        snapshot.oneFlagGroup.secondLevelFlag = false
        try flagPole.save(snapshot: snapshot, to: source)

        XCTAssertEqual(source["top-level-flag"], .bool(true))
        XCTAssertEqual(source["one-flag-group.second-level-flag"], .bool(false))
    }

    // MARK: - Equatable Tests

    func testEquatable() {

        let identifier1 = UUID().uuidString
        let original = FlagValueDictionary(
            id: identifier1,
            storage: [
                "top-level-flag": .bool(true),
            ]
        )

        let same = FlagValueDictionary(
            id: identifier1,
            storage: [
                "top-level-flag": .bool(true),
            ]
        )

        let differentContent = FlagValueDictionary(
            id: identifier1,
            storage: [
                "top-level-flag": .bool(false),
            ]
        )

        let differentIdentifier = FlagValueDictionary(
            id: UUID().uuidString,
            storage: [
                "top-level-flag": .bool(true),
            ]
        )

        XCTAssertEqual(original, same)
        XCTAssertNotEqual(original, differentContent)
        XCTAssertNotEqual(original, differentIdentifier)

    }

    // MARK: - Codable Tests

    func testCodable() throws {
        // BoxedFlagValue's Codable support is more heavily tested in it's tests
        let source: FlagValueDictionary = [
            "bool-flag": .bool(true),
            "string-flag": .string("alpha"),
            "integer-flag": .integer(123),
        ]

        let encoded = try JSONEncoder().encode(source)
        let decoded = try JSONDecoder().decode(FlagValueDictionary.self, from: encoded)

        XCTAssertEqual(source, decoded)
    }


    // MARK: - Publishing Tests

#if canImport(Combine)

    func testPublishesValues() throws {
        throw XCTSkip("Temporarily disabled until we can make it more reliable")
//        let expectation = expectation(description: "publisher")
//        expectation.expectedFulfillmentCount = 3
//
//        let source = FlagValueDictionary()
//        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
//
//        let cancellable = flagPole.flagPublisher
//            .sink { _ in
//                expectation.fulfill()
//            }
//
//        source["top-level-flag"] = .bool(true)
//        source["one-flag-group.second-level-flag"] = .bool(true)
//
//        withExtendedLifetime((cancellable, flagPole)) {
//            wait(for: [ expectation ], timeout: 1)
//        }
    }

#endif

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @FlagGroup(description: "Test 1")
    var oneFlagGroup: OneFlags

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

}

@FlagContainer
private struct OneFlags {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

}
