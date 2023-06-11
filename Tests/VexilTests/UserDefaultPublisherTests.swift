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

#if !os(Linux)

// import Combine
// import Vexil
// import XCTest
//
// final class UserDefaultPublisherTests: XCTestCase {
//
//    func testPublishesWhenUserDefaultsChange() {
//        let expectation = expectation(description: "published")
//
//        let defaults = UserDefaults(suiteName: "Test Suite")!
//        let pole = FlagPole(hoist: TestFlags.self, sources: [ defaults ])
//
//        var snapshots = [Snapshot<TestFlags>]()
//
//        let cancellable = pole.publisher
//            .dropFirst()                        // drop the immediate publish upon subscribing
//            .sink { snapshot in
//                snapshots.append(snapshot)
//                if snapshots.count == 2 {
//                    expectation.fulfill()
//                }
//            }
//
//        defaults.set("Test Value", forKey: "test-key")
//        defaults.set(123, forKey: "second-test-key")
//
//        wait(for: [ expectation ], timeout: 1)
//
//        XCTAssertNotNil(cancellable)
//        XCTAssertEqual(snapshots.count, 2)
//    }
//
//    func testDoesNotPublishWhenDifferentUserDefaultsChange() {
//        let expectation = expectation(description: "published")
//
//        let defaults1 = UserDefaults(suiteName: "Test Suite")!
//        let defaults2 = UserDefaults(suiteName: "Separate Test Suite")!
//        let pole = FlagPole(hoist: TestFlags.self, sources: [ defaults1 ])
//
//        var snapshots = [Snapshot<TestFlags>]()
//
//        let cancellable = pole.publisher
//            .dropFirst()                        // drop the immediate publish upon subscribing
//            .sink { snapshot in
//                snapshots.append(snapshot)
//                if snapshots.count == 1 {
//                    expectation.fulfill()
//                }
//            }
//
//        defaults2.set("Test Value", forKey: "test-key")
//        defaults1.set(123, forKey: "second-test-key")
//
//        wait(for: [ expectation ], timeout: 1)
//
//        XCTAssertNotNil(cancellable)
//        XCTAssertEqual(snapshots.count, 1)
//    }
//
// }
//
//
//// MARK: - Fixtures
//
// private struct TestFlags: FlagContainer {}

#endif
