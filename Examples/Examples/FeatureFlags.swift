import Vexil

@FlagContainer
struct FeatureFlags {

    @Flag("Whether to display the developer menu in the UI")
    var developerMenuEnabled = false

    @Flag("A string flag")
    var string = "Blob"

    @Flag("A number flag")
    var number = 42

}
