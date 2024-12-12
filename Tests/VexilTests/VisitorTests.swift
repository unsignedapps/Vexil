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

import Testing
import Vexil

@Suite("Visitors")
struct VisitorTests {

    @Test("Visits every expected element")
    func visitsEveryElement() {
        let pole = FlagPole(hoist: TestFlags.self, configuration: .init(codingPathStrategy: .kebabcase, prefix: nil, separator: "."), sources: [])
        let visitor = Visitor()
        pole.walk(visitor: visitor)

        #expect(
            visitor.events == [
                .beginContainer(""),        // root
                .visitFlag("top-level-flag"),
                .visitFlag("second-test-flag"),
                .beginGroup("subgroup"),

                .beginContainer("subgroup"),
                .visitFlag("subgroup.second-level-flag"),
                .beginGroup("subgroup.double-subgroup"),

                .beginContainer("subgroup.double-subgroup"),
                .visitFlag("subgroup.double-subgroup.third-level-flag"),
                .endContainer("subgroup.double-subgroup"),

                .endGroup("subgroup.double-subgroup"),
                .endContainer("subgroup"),

                .endGroup("subgroup"),
                .endContainer(""),          // root
            ]
        )
    }
}

// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

@FlagContainer
private struct SubgroupFlags {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
private struct DoubleSubgroupFlags {

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

}

private final class Visitor: FlagVisitor {

    enum Event: Equatable {
        case beginContainer(String)
        case endContainer(String)
        case beginGroup(String)
        case endGroup(String)
        case visitFlag(String)
    }

    var events: [Event] = []

    func beginContainer<Container>(keyPath: FlagKeyPath, containerType: Container.Type) {
        events.append(.beginContainer(keyPath.key))
    }

    func endContainer(keyPath: FlagKeyPath) {
        events.append(.endContainer(keyPath.key))
    }

    func beginGroup<Container>(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<Container>) where Container: FlagContainer {
        events.append(.beginGroup(keyPath.key))
    }

    func endGroup(keyPath: FlagKeyPath) {
        events.append(.endGroup(keyPath.key))
    }

    func visitFlag<Value>(keyPath: FlagKeyPath, value: () -> Value?, defaultValue: Value, wigwag: () -> FlagWigwag<Value>) where Value: FlagValue {
        events.append(.visitFlag(keyPath.key))
    }

}
