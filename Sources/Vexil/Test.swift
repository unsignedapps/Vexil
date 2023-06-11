
struct TestFlags: FlagContainer {

    var _lookup: FlagLookup

    init(_lookup: FlagLookup) {
        self._lookup = _lookup
    }

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

    @FlagGroup(description: "Subgroup of test flags")
    var subgroup: SubgroupFlags

}

struct SubgroupFlags: FlagContainer {

    var _lookup: FlagLookup

    init(_lookup: FlagLookup) {
        self._lookup = _lookup
    }

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

    @FlagGroup(description: "Another level of test flags")
    var doubleSubgroup: DoubleSubgroupFlags

}

struct DoubleSubgroupFlags: FlagContainer {

    var _lookup: FlagLookup

    init(_lookup: FlagLookup) {
        self._lookup = _lookup
    }

    @Flag(default: false, description: "Third level test flag")
    var thirdLevelFlag: Bool

}
