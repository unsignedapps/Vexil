//
// FlagValueSourceManager.swift
// Vexil: Vexilographer
//
// Created by Rob Amos on 29/6/20.
//

import Combine
import Foundation
import SwiftUI
import Vexil

class FlagValueManager<RootGroup>: ObservableObject where RootGroup: FlagContainer {

    // MARK: - Properties

    let flagPole: FlagPole<RootGroup>
    let source: FlagValueSource
    private var cancellables = Set<AnyCancellable>()


    // MARK: - Initialisation

    init (flagPole: FlagPole<RootGroup>, source: FlagValueSource) {
        self.flagPole = flagPole
        self.source = source

        flagPole
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &self.cancellables)
    }


    // MARK: - Updating Flag Values

    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue {
        let snapshot = self.flagPole.emptySnapshot()
        try snapshot.setFlagValue(value, key: key)
        try self.flagPole.save(snapshot: snapshot, to: self.source)
    }


    // MARK: - Displaying Flag Values

    func allItems () -> [UnfurledFlagItem] {
        return Mirror(reflecting: self.flagPole._rootGroup)
            .children
            .compactMap { child -> UnfurledFlagItem? in
                guard let label = child.label, let unfurlable = child.value as? Unfurlable else { return nil }
                let unfurled = unfurlable.unfurl(label: label, manager: self)
                print("\(unfurled.name) - \(unfurled.id)")
                return unfurled
            }
    }

}
