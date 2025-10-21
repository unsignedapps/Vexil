//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
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

@Suite("FlagValueSource", .tags(.pole, .source))
struct FlagValueSourceTests {

    @Test("Reads values from source")
    func readsFromSource() {
        let accessedKeys = Lock(initialState: [String]())
        let values = [
            "test-flag": true,
            "second-test-flag": false,
        ]

        let source = TestGetSource(values: values) { key in
            accessedKeys.withLock {
                $0.append(key)
            }
        }

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        // test the source has the right values, this triggers the subject above
        #expect(pole.secondTestFlag == false)
        #expect(pole.testFlag)

        let keys = accessedKeys.withLock { $0 }
        #expect(keys.count == 2)
        #expect(keys.first == "second-test-flag")
        #expect(keys.last == "test-flag")
    }

    @Test("Writes values to source", .tags(.snapshot))
    func writesToSource() throws {
        let setEvents = Lock(initialState: [TestSetSource.Event]())
        let source = TestSetSource { event in
            setEvents.withLock {
                $0.append(event)
            }
        }

        let pole = FlagPole(hoist: TestFlags.self, sources: [ source ])

        let snapshot = pole.emptySnapshot()
        snapshot.secondTestFlag = false
        snapshot.testFlag = true

        try pole.save(snapshot: snapshot, to: source)

        let events = setEvents.withLock { $0 }
        #expect(events.count == 2)
        #expect(events.first?.0 == "test-flag")
        #expect(events.first?.1 == true)
        #expect(events.last?.0 == "second-test-flag")
        #expect(events.last?.1 == false)
    }

    @Test("Copies between sources", .tags(.copying, .dictionary))
    func copies() throws {

        // GIVEN two dictionaries
        let source = FlagValueDictionary([
            "test-flag": .bool(true),
            "subgroup.test-flag": .bool(true),
        ])
        let destination = FlagValueDictionary()

        // WHEN we copy from the source to the destination
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        try pole.copyFlagValues(from: source, to: destination)

        // THEN we expect those two dictionaries to match
        let destinationValues = destination.allValues
        #expect(destinationValues.count == 2)
        #expect(destinationValues["test-flag"] == .bool(true))
        #expect(destinationValues["subgroup.test-flag"] == .bool(true))

    }

    @Test("Removes from source", .tags(.removing))
    func removesAll() throws {

        // GIVEN a dictionary with some values
        let source = FlagValueDictionary([
            "test-flag": .bool(true),
            "subgroup.test-flag": .bool(true),
        ])

        // WHEN we remove all values from that source
        let pole = FlagPole(hoist: TestFlags.self, sources: [])
        try pole.removeFlagValues(in: source)

        // THEN the source should now be empty
        let sourceValues = source.allValues
        #expect(sourceValues.isEmpty)

    }

}


// MARK: - Fixtures

@FlagContainer
private struct TestFlags {

    @Flag("This is a test flag")
    var testFlag = false

    @Flag("This is another test flag")
    var secondTestFlag = true

    @FlagGroup("A test subgroup")
    var subgroup: Subgroup
}

@FlagContainer
private struct Subgroup {

    @Flag("A test flag in a subgroup")
    var testFlag = false

}

private final class TestGetSource: FlagValueSource {

    let flagValueSourceID = UUID().uuidString
    let flagValueSourceName = "Test Source"
    let subject: @Sendable (String) -> Void
    let values: [String: Bool]

    init(values: [String: Bool], subject: @escaping @Sendable (String) -> Void) {
        self.values = values
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        subject(key)
        return values[key] as? Value
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {}

    func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> EmptyFlagChangeStream {
        .init()
    }

}


private final class TestSetSource: FlagValueSource {

    typealias Event = (String, Bool)

    let flagValueSourceID = UUID().uuidString
    let flagValueSourceName = "Test Source"
    let subject: @Sendable (Event) -> Void

    init(subject: @escaping @Sendable (Event) -> Void) {
        self.subject = subject
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        nil
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        guard let value = value as? Bool else {
            return
        }
        subject((key, value))
    }

    func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> EmptyFlagChangeStream {
        .init()
    }

}
