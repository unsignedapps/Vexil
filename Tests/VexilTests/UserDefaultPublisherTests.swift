//
//  UserDefaultPublisherTests.swift
//  Vexil
//
//  Created by Rob Amos on 2/8/20.
//

#if !os(Linux)

import Combine
import Vexil
import XCTest

final class UserDefaultPublisherTests: XCTestCase {

    func testPublishesWhenUserDefaultsChange () {
        let expectation = self.expectation(description: "published")

        let defaults = UserDefaults(suiteName: "Test Suite")!
        let pole = FlagPole(hoist: TestFlags.self, sources: [ defaults ])

        var snapshots = [Snapshot<TestFlags>]()

        let cancellable = pole.publisher
            .dropFirst()                        // drop the immediate publish upon subscribing
            .sink { snapshot in
                snapshots.append(snapshot)
                if snapshots.count == 2 {
                    expectation.fulfill()
                }
            }

        defaults.set("Test Value", forKey: "test-key")
        defaults.set(123, forKey: "second-test-key")

        self.wait(for: [ expectation ], timeout: 1)

        XCTAssertNotNil(cancellable)
        XCTAssertEqual(snapshots.count, 2)
    }

}


// MARK: - Fixtures

private struct TestFlags: FlagContainer {
}

#endif
