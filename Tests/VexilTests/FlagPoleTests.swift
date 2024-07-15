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

final class FlagPoleTests: XCTestCase {

    func testSetsDefaultSources() throws {
        let pole = FlagPole(hoist: TestFlags.self)

        XCTAssertEqual(pole._sources.count, 1)
        try XCTUnwrap(pole._sources.first as? FlagValueSourceCoordinator<UserDefaults>).source.withLock {
            XCTAssertTrue($0 === UserDefaults.standard)
        }
    }

}

// MARK: - Fixtures

@FlagContainer(generateEquatable: false)
private struct TestFlags {}
