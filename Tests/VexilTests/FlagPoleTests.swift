//
//  FlagPoleTests.swift
//  Vexil
//
//  Created by Rob Amos on 2/8/20.
//

import Foundation
import Vexil
import XCTest

final class FlagPoleTests: XCTestCase {

    func testSetsDefaultSources () {
        let pole = FlagPole(hoist: TestFlags.self)

        XCTAssertEqual(pole._sources.count, 1)
        XCTAssertTrue(pole._sources.first as AnyObject === UserDefaults.standard)
    }
}

// MARK: - Fixtures

private struct TestFlags: FlagContainer {

}
