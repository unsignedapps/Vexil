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

#if canImport(Combine)

import AsyncAlgorithms
import Combine
@testable import Vexil
import XCTest

final class PublisherTests: XCTestCase {

    // MARK: - Flag Pole Publisher

    func testPublisherSetup() {
        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        // First subscriber
        let expectation1 = expectation(description: "group emitted")
        let cancellable1 = pole.flagPublisher
            .sink { _ in
                expectation1.fulfill()
            }

        withExtendedLifetime(cancellable1) {
            wait(for: [ expectation1 ], timeout: 1)
        }

        // Subsequence subscriber
        let expectation2 = expectation(description: "group emitted")
        let cancellable2 = pole.flagPublisher
            .sink { _ in
                expectation2.fulfill()
            }

        withExtendedLifetime(cancellable2) {
            wait(for: [ expectation2 ], timeout: 1)
        }
    }

    func testPublishesWhenAddingSource() {
        let expectation = expectation(description: "group emitted")
        expectation.expectedFulfillmentCount = 2

        let pole = FlagPole(hoist: TestFlags.self, sources: [])

        let cancellable = pole.flagPublisher
            .sink { _ in
                expectation.fulfill()
            }

        let change = pole.emptySnapshot()
        change.testFlag = true
        pole.append(snapshot: change)

        withExtendedLifetime(cancellable) {
            wait(for: [ expectation ], timeout: 1)
        }
    }

    func testPublishesWhenSourceChanges() {
        let expectation = expectation(description: "published")
        expectation.expectedFulfillmentCount = 3
        let source = TestSource()
        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        let cancellable = pole.flagPublisher
            .sink { _ in
                expectation.fulfill()
            }

        source.continuation.yield(.all)
        source.continuation.yield(.all)

        withExtendedLifetime((cancellable, pole)) {
            wait(for: [ expectation ], timeout: 1)
        }
    }

    func testPublishesWithMultipleSources() {
        let expectation = expectation(description: "published")
        expectation.expectedFulfillmentCount = 3

        let source1 = TestSource()
        let source2 = TestSource()

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source1, source2 ])

        let cancellable = pole.flagPublisher
            .sink { snapshot in
                expectation.fulfill()
            }

        source1.continuation.yield(.all)
        source2.continuation.yield(.all)

        withExtendedLifetime((cancellable, pole)) {
            wait(for: [ expectation ], timeout: 1)
        }
    }


    // MARK: - Individual Flag Publishers

    //    func testIndividualFlagPublisher() {
    //        let expectation = expectation(description: "publisher")
    //        expectation.expectedFulfillmentCount = 2
    //
    //        let pole = FlagPole(hoist: TestFlags.self, sources: [])
    //
    //        var values: [Bool] = []
    //
    //        let cancellable = pole.$testFlag.publisher
    //            .sink { value in
    //                values.append(value)
    //                expectation.fulfill()
    //            }
    //
    //        let change = pole.emptySnapshot()
    //        change.testFlag = true
    //        pole.append(snapshot: change)
    //
    //        wait(for: [ expectation ], timeout: 1)
    //
    //        XCTAssertNotNil(cancellable)
    //        XCTAssertEqual(values.count, 2)
    //        XCTAssertEqual(values.first, false)
    //        XCTAssertEqual(values.last, true)
    //    }
    //
    //
    //    func testIndividualFlagPublisheRemovesDuplicates() {
    //        let expectation = expectation(description: "publisher")
    //        expectation.expectedFulfillmentCount = 2
    //
    //        let pole = FlagPole(hoist: TestFlags.self, sources: [])
    //
    //        var values: [Bool] = []
    //
    //        let cancellable = pole.$testFlag.publisher
    //            .sink { value in
    //                values.append(value)
    //                expectation.fulfill()
    //            }
    //
    //        let change = pole.emptySnapshot()
    //        change.testFlag = true
    //        pole.append(snapshot: change)
    //        pole.append(snapshot: change)
    //
    //        wait(for: [ expectation ], timeout: 1)
    //
    //        XCTAssertNotNil(cancellable)
    //        XCTAssertEqual(values.count, 2)
    //        XCTAssertEqual(values.first, false)
    //        XCTAssertEqual(values.last, true)
    //    }


    // MARK: - Setup

    //    func testSendsAllKeysToSourceDuringSetup() throws {
    //
    //        // GIVEN a flag pole and a mock source
    //        let source = TestSource()
    //        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])
    //
    //        // WHEN we setup a publisher (we don't actually need it, but we want it to
    //        // do a full setup)
    //        let cancellable = pole.publisher
    //            .sink { _ in
    //                // Intentionally left blank
    //            }
    //
    //        // THEN we expect the source to have been told about all the keys
    //        XCTAssertEqual(
    //            source.requestedKeys,
    //            [
    //                "test-flag",
    //                "test-flag2",
    //                "test-flag3",
    //                "test-flag4",
    //            ]
    //        )
    //        XCTAssertNotNil(cancellable)
    //    }

}

// MARK: - Test Fixtures


@FlagContainer
private struct TestFlags {

    @Flag(default: false, description: "This is a test flag")
    var testFlag: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag2: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag3: Bool

    @Flag(default: false, description: "This is a test flag")
    var testFlag4: Bool

}

private final class TestSource: FlagValueSource {
    var name = "Test Source"

    let stream: AsyncStream<FlagChange>
    let continuation: AsyncStream<FlagChange>.Continuation

    init() {
        let (stream, continuation) = AsyncStream<FlagChange>.makeStream()
        self.stream = stream
        self.continuation = continuation
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        nil
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {}

    var changeStream: AsyncStream<FlagChange> {
        stream
    }

}

#endif
