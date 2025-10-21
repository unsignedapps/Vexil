import Vexil

@FlagContainer
struct FeatureFlags {

    @Flag(description: "Whether to display the developer menu in the UI", display: .hidden)
    var developerMenuEnabled = false

    @FlagGroup(description: "Builtin types", display: .section)
    var builtinTypes: BuiltinTypes

    @FlagGroup("Custom flags")
    var customFlags: CustomFlags

}

@FlagContainer
struct BuiltinTypes {

    @Flag("A boolean flag")
    var boolean = true

    @Flag("An optional boolean flag")
    var optionalBoolean: Bool?

    @Flag("A string flag")
    var string = "Blob"

    @Flag("An optional string flag")
    var optionalString: String?

    @Flag("An integer flag")
    var integer = 42

    @Flag("An optional integer flag")
    var optionalInteger: Int?

    @Flag("A double flag")
    var double = 1729.42

    @Flag("An optional double flag")
    var optionalDouble: Double?

    @Flag("An case iterable flag")
    var caseIterable = Enum.foo

    @Flag("An optional case iterable flag")
    var optionalCaseIterable: Enum?

    enum Enum: String, CaseIterable, FlagValue {
        case foo
        case bar
        case baz
    }

}

@FlagContainer
struct CustomFlags {

    @Flag("A boolean flag")
    var boolean = true

    @Flag("A double flag")
    var double = 1729.42

    @Flag("A double and boolaen flag")
    var doubleAndBoolean = DoubleAndBoolean()

    struct DoubleAndBoolean: Codable, Equatable, FlagValue {
        var percent = 0.5
        var isEnabled = false
    }

}
