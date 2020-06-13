//
//  SnapshotSource.swift
//  Vexil
//
//  Created by Rob Amos on 11/6/20.
//

import Combine
import Foundation

class SnapshotSource<RootGroup>: FlagValueSource where RootGroup: FlagContainer {

    // MARK: - Properties

    var snapshots: [Snapshot<RootGroup>]


    // MARK: - Initialisation

    convenience init (snapshot: Snapshot<RootGroup>) {
        self.init()
        self.snapshots.append(snapshot)
    }

    init () {
        self.snapshots = []
    }


    // MARK: - Snapshot Management

    func add (snapshot: Snapshot<RootGroup>) {
        self.snapshots.insert(snapshot, at: 0)
    }

    func remove (snapshot: Snapshot<RootGroup>) {
        self.snapshots.removeAll(where: { $0 == snapshot })
    }


    // MARK: - Flag Value Source

    func flagValue<Value> (key: String) -> Value? where Value: FlagValue {
        return self.snapshots
            .lazy
            .compactMap { $0.flagValue(key: key) }
            .first
    }

    func setFlagValue<Value>(_ value: Value?, key: String) throws where Value: FlagValue {
        assertionFailure("Snapshots cannot be mutated by applying other snapshots")
    }


    // MARK: - Real Time Flag Values

    lazy var latestChanges = PassthroughSubject<Void, Never>()
    var valuesDidChange: AnyPublisher<Void, Never>? {
        return self.latestChanges.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    private func setupChangePublishing () {

        // cancel our existing one
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

        let upstream = self.snapshots.compactMap { $0.valuesDidChange }
        guard upstream.isEmpty == false else { return }

        Publishers.MergeMany(upstream)
            .sink { [weak self] in
                guard let self = self else { return }
                self.latestChanges.send()
            }
            .store(in: &self.cancellables)
    }
}
