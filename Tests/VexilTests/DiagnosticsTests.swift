//
//  DiagnosticsTests.swift
//  Vexil
//
//  Created by Rob Amos on 12/12/21.
//

// swiftlint:disable function_body_length

#if canImport(Combine)

import Combine
import Vexil
import XCTest

final class DiagnosticsTests: XCTestCase {

    func testEmitsExpectedDiagnostics() throws {

        // GIVEN a FlagPole with three different FlagSources
        let source1 = FlagValueDictionary([
            "top-level-flag": .bool(true)
        ])
        let source2 = FlagValueDictionary([
            "subgroup.second-level-flag": .bool(true)
        ])
        let source3 = FlagValueDictionary([
            "top-level-flag": .bool(true),
            "second-test-flag": .bool(true),
            "subgroup.second-level-flag": .bool(true)
        ])
        let pole = FlagPole(hoist: TestFlags.self, sources: [ source1, source2 ])

        var receivedDiagnostics: [[FlagPoleDiagnostic]] = []
        let expectation = self.expectation(description: "received diagnostics")
        expectation.expectedFulfillmentCount = 5
        expectation.assertForOverFulfill = true

        // WHEN we subscribe to diagnostics and then make a bunch of changes
        let cancellable = pole.makeDiagnosticsPublisher()
            .sink {
                receivedDiagnostics.append($0)
                expectation.fulfill()
            }

        // 1. Change a value in the top source that is still a default
        source1["second-test-flag"] = .bool(true)

        // 2. Change a value in the source source that will be overridden by the first source regardless
        source2["top-level-flag"] = .bool(false)

        // 3. Insert a new source into the hierarchy between the two sources
        pole._sources.insert(source3, at: 1)

        // 4. Remove that source again
        pole._sources.removeAll(where: { $0.name == source3.name })

        // THEN everything should line up with the above changes
        self.wait(for: [ expectation ], timeout: 1.0)
        XCTAssertEqual(receivedDiagnostics.count, 5)

        // 0. We should have gotten the default value of all flags
        let initial = receivedDiagnostics[safe: 0]
        XCTAssertEqual(initial?.count, 4)
        XCTAssertEqual(initial?[safe: 0], .currentValue(key: "second-test-flag", value: .bool(false), resolvedBy: nil))
        XCTAssertEqual(initial?[safe: 1], .currentValue(key: "subgroup.double-subgroup.third-level-flag", value: .bool(false), resolvedBy: nil))
        XCTAssertEqual(initial?[safe: 2], .currentValue(key: "subgroup.second-level-flag", value: .bool(true), resolvedBy: source2.name))
        XCTAssertEqual(initial?[safe: 3], .currentValue(key: "top-level-flag", value: .bool(true), resolvedBy: source1.name))

        // 1. Changed value in the top source, it should be resolved by that source
        let first = receivedDiagnostics[safe: 1]
        XCTAssertEqual(first?.count, 1)
        XCTAssertEqual(first?[safe: 0], .changedValue(key: "second-test-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source1.name))

        // 2. Changed value in the second source, but there is also a value set in the top source
        let second = receivedDiagnostics[safe: 2]
        XCTAssertEqual(second?.count, 1)
        XCTAssertEqual(second?[safe: 0], .changedValue(key: "top-level-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source2.name))

        // 3. Inserted new source into the hierarchy, with one overridden, one overriding, and one unique value
        let third = receivedDiagnostics[safe: 3]
        XCTAssertEqual(third?.count, 4)
        XCTAssertEqual(third?[safe: 0], .changedValue(key: "second-test-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source3.name))
        XCTAssertEqual(third?[safe: 1], .changedValue(key: "subgroup.double-subgroup.third-level-flag", value: .bool(false), resolvedBy: nil, changedBy: source3.name))
        XCTAssertEqual(third?[safe: 2], .changedValue(key: "subgroup.second-level-flag", value: .bool(true), resolvedBy: source3.name, changedBy: source3.name))
        XCTAssertEqual(third?[safe: 3], .changedValue(key: "top-level-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source3.name))

        // 3. Inserted that source again, values should reflect previous state with source3 as the changedBy
        let fourth = receivedDiagnostics[safe: 4]
        XCTAssertEqual(fourth?.count, 4)
        XCTAssertEqual(fourth?[safe: 0], .changedValue(key: "second-test-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source3.name))
        XCTAssertEqual(fourth?[safe: 1], .changedValue(key: "subgroup.double-subgroup.third-level-flag", value: .bool(false), resolvedBy: nil, changedBy: source3.name))
        XCTAssertEqual(fourth?[safe: 2], .changedValue(key: "subgroup.second-level-flag", value: .bool(true), resolvedBy: source2.name, changedBy: source3.name))
        XCTAssertEqual(fourth?[safe: 3], .changedValue(key: "top-level-flag", value: .bool(true), resolvedBy: source1.name, changedBy: source3.name))

        XCTAssertNotNil(cancellable)
    }

}


// MARK: - Fixtures

private struct TestFlags: FlagContainer {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

private struct SubgroupFlags: FlagContainer {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

private struct DoubleSubgroupFlags: FlagContainer {

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

}

#endif // canImport(Combine)
