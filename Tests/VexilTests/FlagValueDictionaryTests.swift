//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

// import Foundation
// @testable import Vexil
// import XCTest
//
// final class FlagValueDictionaryTests: XCTestCase {
//
//    // MARK: - Reading Values
//
//    func testReadsValues() {
//        let source: FlagValueDictionary = [
//            "top-level-flag": .bool(true),
//        ]
//
//        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
//        XCTAssertTrue(flagPole.topLevelFlag)
//        XCTAssertFalse(flagPole.oneFlagGroup.secondLevelFlag)
//    }
//
//
//    // MARK: - Writing Values
//
//    func testWritesValues() throws {
//        let source = FlagValueDictionary()
//        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
//
//        let snapshot = flagPole.emptySnapshot()
//        snapshot.topLevelFlag = true
//        snapshot.oneFlagGroup.secondLevelFlag = false
//        try flagPole.save(snapshot: snapshot, to: source)
//
//        XCTAssertEqual(source.storage["top-level-flag"], .bool(true))
//        XCTAssertEqual(source.storage["one-flag-group.second-level-flag"], .bool(false))
//    }
//
//    // MARK: - Equatable Tests
//
//    func testEquatable() {
//
//        let identifier1 = UUID()
//        let original = FlagValueDictionary(
//            id: identifier1,
//            storage: [
//                "top-level-flag": .bool(true),
//            ]
//        )
//
//        let same = FlagValueDictionary(
//            id: identifier1,
//            storage: [
//                "top-level-flag": .bool(true),
//            ]
//        )
//
//        let differentContent = FlagValueDictionary(
//            id: identifier1,
//            storage: [
//                "top-level-flag": .bool(false),
//            ]
//        )
//
//        let differentIdentifier = FlagValueDictionary(
//            id: UUID(),
//            storage: [
//                "top-level-flag": .bool(true),
//            ]
//        )
//
//        XCTAssertEqual(original, same)
//        XCTAssertNotEqual(original, differentContent)
//        XCTAssertNotEqual(original, differentIdentifier)
//
//    }
//
//    // MARK: - Codable Tests
//
//    func testCodable() throws {
//        // BoxedFlagValue's Codable support is more heavily tested in it's tests
//        let source: FlagValueDictionary = [
//            "bool-flag": .bool(true),
//            "string-flag": .string("alpha"),
//            "integer-flag": .integer(123),
//        ]
//
//        let encoded = try JSONEncoder().encode(source)
//        let decoded = try JSONDecoder().decode(FlagValueDictionary.self, from: encoded)
//
//        XCTAssertEqual(source, decoded)
//    }
//
//
//    // MARK: - Publishing Tests
//
// #if !os(Linux)
//
//    func testPublishesValues() {
//        let expectation = expectation(description: "publisher")
//        expectation.expectedFulfillmentCount = 3
//
//        let source = FlagValueDictionary()
//        let flagPole = FlagPole(hoist: TestFlags.self, sources: [ source ])
//
//        var snapshots = [Snapshot<TestFlags>]()
//        let cancellable = flagPole.publisher
//            .sink { snapshot in
//                snapshots.append(snapshot)
//                expectation.fulfill()
//            }
//
//        source["top-level-flag"] = .bool(true)
//        source["one-flag-group.second-level-flag"] = .bool(true)
//
//        wait(for: [ expectation ], timeout: 1)
//
//        XCTAssertNotNil(cancellable)
//        XCTAssertEqual(snapshots.count, 3)
//        XCTAssertEqual(snapshots[safe: 0]?.topLevelFlag, false)
//        XCTAssertEqual(snapshots[safe: 0]?.oneFlagGroup.secondLevelFlag, false)
//        XCTAssertEqual(snapshots[safe: 1]?.topLevelFlag, true)
//        XCTAssertEqual(snapshots[safe: 1]?.oneFlagGroup.secondLevelFlag, false)
//        XCTAssertEqual(snapshots[safe: 2]?.topLevelFlag, true)
//        XCTAssertEqual(snapshots[safe: 2]?.oneFlagGroup.secondLevelFlag, true)
//    }
//
// #endif
//
// }
//
//
//// MARK: - Fixtures
//
//
// private struct TestFlags: FlagContainer {
//
//    @FlagGroup(description: "Test 1")
//    var oneFlagGroup: OneFlags
//
//    @Flag(description: "Top level test flag")
//    var topLevelFlag = false
//
// }
//
// private struct OneFlags: FlagContainer {
//
//    @Flag(default: false, description: "Second level test flag")
//    var secondLevelFlag: Bool
// }
