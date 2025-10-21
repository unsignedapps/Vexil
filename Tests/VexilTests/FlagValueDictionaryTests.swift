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
import Testing
@testable import Vexil

@Suite("FlagValueDictionary", .tags(.dictionary))
struct FlagValueDictionaryTests {

    // MARK: - Reading Values

    @Test("Gets flag value when FlagValueSource", .tags(.pole))
    func readsValues() {
        let source: FlagValueDictionary = [
            "top-level-flag": .bool(true),
        ]

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])
        #expect(pole.topLevelFlag)
        #expect(pole.oneFlagGroup.secondLevelFlag == false)
    }


    // MARK: - Writing Values

    @Test("Sets flag value when FlagValueSource", .tags(.pole, .saving))
    func writesValues() throws {
        let source = FlagValueDictionary()
        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        let snapshot = flagPole.emptySnapshot()
        snapshot.topLevelFlag = true
        snapshot.oneFlagGroup.secondLevelFlag = false
        try flagPole.save(snapshot: snapshot, to: source)

        let allValues = source.allValues
        #expect(allValues["top-level-flag"] == .bool(true))
        #expect(allValues["one-flag-group.second-level-flag"] == .bool(false))
    }

    // MARK: - Equatable Tests

    @Test("Supports Equatable")
    func equatable() {

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

        let originalValues = original.allValues
        let sameValues = same.allValues
        let differentContentValues = differentContent.allValues
        let differentIdentifierValues = differentIdentifier.allValues
        #expect(originalValues == sameValues)
        #expect(originalValues != differentContentValues)
        #expect(originalValues == differentIdentifierValues)
        #expect(original.id != differentIdentifier.id)

    }

    // MARK: - Codable Tests

    @Test("Supports Codable", .tags(.codable))
    func codable() throws {
        // BoxedFlagValue's Codable support is more heavily tested in it's tests
        let source: FlagValueDictionary = [
            "bool-flag": .bool(true),
            "string-flag": .string("alpha"),
            "integer-flag": .integer(123),
        ]

        let encoded = try JSONEncoder().encode(source)
        let decoded = try JSONDecoder().decode(FlagValueDictionary.self, from: encoded)

        #expect(source.allValues == decoded.allValues)
        #expect(source.id == decoded.id)
    }


    // MARK: - Publishing Tests

    // #if canImport(Combine)
//
//    func testPublishesValues() throws {
//        throw XCTSkip("Temporarily disabled until we can make it more reliable")
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
//    }
//
    // #endif

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @FlagGroup(description: "Test 1")
    var oneFlagGroup: OneFlags

    @Flag("Top level test flag")
    var topLevelFlag = false

}

@FlagContainer
private struct OneFlags {

    @Flag("Second level test flag")
    var secondLevelFlag = false

}
