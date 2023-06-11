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

#if os(iOS) || os(macOS)

import Combine
import Foundation
import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
class FlagValueManager<RootGroup>: ObservableObject where RootGroup: FlagContainer {

    // MARK: - Properties

    let flagPole: FlagPole<RootGroup>
    let source: FlagValueSource?
    private var cancellables = Set<AnyCancellable>()

    var isEditable: Bool {
        source != nil
    }


    // MARK: - Initialisation

    init(flagPole: FlagPole<RootGroup>, source: FlagValueSource?) {
        self.flagPole = flagPole
        self.source = source

        flagPole
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }


    // MARK: - Flag Values

    func rawValue<Value>(key: String) -> Value? where Value: FlagValue {
        source?.flagValue(key: key)
    }

    func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        let snapshot = flagPole.snapshot()
        return snapshot.flagValue(key: key)
    }

    func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        guard let source else {
            return
        }

        let snapshot = flagPole.emptySnapshot()
        try snapshot.setFlagValue(value, key: key)
        try flagPole.save(snapshot: snapshot, to: source)
    }

    func hasValueInSource<Value>(flag: Flag<Value>) -> Bool {
        if let _: Value = source?.flagValue(key: flag.key) {
            return true

        } else {
            return false
        }
    }


    // MARK: - Boxed Values

    func boxedValue<Value>(key: String, type: Value.Type) -> Value.BoxedValueType? where Value: FlagValue {
        guard let value: Value = flagValue(key: key) else {
            return nil
        }
        return value.unwrappedBoxedValue()
    }

    func setBoxedValue<Value>(_ value: Value.BoxedValueType?, type: Value.Type, key: String) throws where Value: FlagValue {
        let unboxed = value.flatMap(Value.init(unwrapped:))
        try setFlagValue(unboxed, key: key)
    }


    // MARK: - Displaying Flag Values

    func allItems() -> [UnfurledFlagItem] {
        Mirror(reflecting: flagPole._rootGroup)
            .children
            .compactMap { child -> UnfurledFlagItem? in
                guard let label = child.label, let unfurlable = child.value as? Unfurlable else {
                    return nil
                }
                let unfurled = unfurlable.unfurl(label: label, manager: self)
                return unfurled
            }
    }

}

#endif
