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

import Foundation
import Vexil
import XCTest

final class FlagPoleTests: XCTestCase {

    func testSetsDefaultSources() {
        let pole = FlagPole(hoist: TestFlags.self)

        XCTAssertEqual(pole._sources.count, 1)
        XCTAssertTrue(pole._sources.first as AnyObject === UserDefaults.standard)
    }

}

// MARK: - Fixtures

@FlagContainer
private struct TestFlags {}
