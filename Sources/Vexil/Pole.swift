//
//  FlagPole.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Combine
import Foundation

@dynamicMemberLookup
public class FlagPole<RootGroup> where RootGroup: FlagContainer {

    // MARK: - Configuration

    public let configuration: VexilConfiguration


    // MARK: - Sources

    public var sources: [FlagValueSource] {
        didSet {
            if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                self.setupSnapshotPublishing()
            }
        }
    }

    public static var defaultSources: [FlagValueSource] {
        return [
            UserDefaults.standard
        ]
    }


    // MARK: - Initialisation

    public init (hoist: RootGroup.Type, configuration: VexilConfiguration = .default, sources: [FlagValueSource]? = nil) {
        self._rootGroup = hoist.init()
        self.configuration = configuration
        self.sources = sources ?? Self.defaultSources
        self.decorateRootGroup()

        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            self.setupSnapshotPublishing()
        }
    }


    // MARK: - Flag Management

    internal var _rootGroup: RootGroup

    public subscript<Value> (dynamicMember dynamicMember: KeyPath<RootGroup, Value>) -> Value {
        return self._rootGroup[keyPath: dynamicMember]
    }

    public subscript (dynamicMember dynamicMember: KeyPath<RootGroup, Bool>) -> Bool {
        return self._rootGroup[keyPath: dynamicMember]
    }

    private func decorateRootGroup () {
        let prefix = self.configuration.prefix ?? ""

        Mirror(reflecting: self._rootGroup)
            .children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: self, label: $0.label, codingPath: [ prefix ])
            }
    }


    // MARK: - Real Time Changes

    private lazy var latestSnapshot = PassthroughSubject<Snapshot<RootGroup>, Never>()

    public var publisher: AnyPublisher<Snapshot<RootGroup>, Never> {
        self.latestSnapshot.eraseToAnyPublisher()
    }

    private lazy var cancellables = Set<AnyCancellable>()

    private func setupSnapshotPublishing () {

        // cancel our existing one
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

        let upstream = self.sources.compactMap { $0.valuesDidChange }
        guard upstream.isEmpty == false else { return }

        Publishers.MergeMany(upstream)
            .sink { [weak self] in
                guard let self = self else { return }
                self.latestSnapshot.send(self.snapshot())
            }
            .store(in: &self.cancellables)
    }


    // MARK: - Snapshots

    public func snapshot () -> Snapshot<RootGroup> {
        return Snapshot(flagPole: self, copyCurrentFlagValues: true)
    }

    public func emptySnapshot () -> Snapshot<RootGroup> {
        return Snapshot(flagPole: self, copyCurrentFlagValues: false)
    }

    private lazy var snapshotSource: SnapshotSource<RootGroup> = {
        let source = SnapshotSource<RootGroup>()
        self.sources.insert(source, at: 0)
        return source
    }()

    public func apply (snapshot: Snapshot<RootGroup>) {
        self.snapshotSource.add(snapshot: snapshot)
    }

    public func remove (snapshot: Snapshot<RootGroup>) {
        self.snapshotSource.remove(snapshot: snapshot)
    }


    // MARK: - Mutating Flag Sources

    public func save (snapshot: Snapshot<RootGroup>, to source: FlagValueSource) throws {
        try snapshot.allFlags()
            .filter { $0.isDirty == true }
            .forEach { try $0.save(to: source) }
    }
}
