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
import Testing
@testable import Vexil

#if compiler(<6)

import XCTest

final class FlagPoleTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(FlagPoleTests.self, hostedBy: self)
    }
}

#endif

@Suite("Flag Pole")
struct FlagPoleTests {


#if !os(Linux)

    @Test("Sets default sources", .tags(.pole))
    func setsDefaultSources() throws {
        let pole = FlagPole(hoist: TestFlags.self)

        #expect(pole._sources.count == 1)
        let coordinator = try #require(pole._sources.first as? FlagValueSourceCoordinator<UserDefaults>)
        coordinator.source.withLock {
            #expect($0 === UserDefaults.standard)
        }
    }

#else

    @Test("Sets default sources", .tags(.pole))
    func setsDefaultSources() throws {
        let pole = FlagPole(hoist: TestFlags.self)
        #expect(pole._sources.isEmpty)
    }

#endif

}

// MARK: - Fixtures

@FlagContainer(generateEquatable: false)
private struct TestFlags {}
