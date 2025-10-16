import SwiftUI
import Vexil

struct FlagPoleContext {

    var items: [any FlagPoleItem] = []
    var editableSource: (any FlagValueSource)?
    var sources: [any FlagValueSource] = []
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()
    var styles = [AnyHashable: any FlagControlStyle]()

    func items(matching searchText: String) -> [any FlagPoleItem] {
        items.flatMap { $0.items(matching: searchText) }
    }

    @MainActor func styledControl<Value: FlagValue>(configuration: FlagControlConfiguration<Value>) -> AnyView? {
        if let keyPath = keyPathByFlagKeyPath[configuration.keyPath], let style = styles[keyPath] {
            style.control(configuration: configuration)
        } else if let style = styles[ObjectIdentifier(Value.self)] {
            style.control(configuration: configuration)
        } else {
            nil
        }
    }

}

extension EnvironmentValues {

    @Entry var flagPoleContext = FlagPoleContext()

}
