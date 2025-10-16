import Vexil

struct Dependencies {
    var flags = FlagPole(
        hoist: FeatureFlags.self,
        sources: FlagPole<FeatureFlags>.defaultSources + [RemoteFlags.values]
    )

    @TaskLocal static var current = Dependencies()
}

enum RemoteFlags {
    static let values = FlagValueDictionary()
}
