import SwiftUI
import Vexil

extension FlagContainer {
    var keyPathByFlagKeyPath: [FlagKeyPath: AnyKeyPath] {
        _allFlagKeyPaths.reduce(into: [FlagKeyPath: AnyKeyPath]()) { $0[$1.value] = $1.key }
    }
}

class FlagPoleVisitor: FlagVisitor {

    var lookup: any FlagLookup
    var items = [any FlagPoleItem]()
    var groupStack = [any FlagPoleItemGroup]()
    var keyPathStack = [AnyKeyPath]()
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()

    init(lookup: any FlagLookup) {
        self.lookup = lookup
    }

    func beginContainer(keyPath: FlagKeyPath, containerType: any FlagContainer.Type) {
        let container = containerType.init(_flagKeyPath: keyPath, _flagLookup: lookup)
        keyPathByFlagKeyPath.merge(container.keyPathByFlagKeyPath, uniquingKeysWith: { $1 })
    }

    func beginGroup(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<some FlagContainer>) {
        groupStack.append(FlagGroupItem(wigwag()))
    }

    func visitFlag<Value: FlagValue>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) {
        appendToGroupOrRoot(FlagItem(wigwag()))
    }

    func endGroup(keyPath: FlagKeyPath) {
        appendToGroupOrRoot(groupStack.removeLast())
    }

    private func appendToGroupOrRoot(_ newItem: any FlagPoleItem) {
        if groupStack.last != nil {
            groupStack[groupStack.count - 1].items.append(newItem)
        } else {
            items.append(newItem)
        }
    }

}
