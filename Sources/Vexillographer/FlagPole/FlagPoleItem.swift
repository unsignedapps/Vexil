import SwiftUI
import Vexil

protocol FlagPoleItem {

    var keyPath: FlagKeyPath { get }
    var name: String { get }
    var isHidden: Bool { get }
    @MainActor func makeContent() -> any View

}

extension FlagPoleItem {
    @MainActor var content: AnyView { AnyView(makeContent()) }
}

extension FlagPoleItem {

    func matches(searchText: String) -> Bool {
        searchText.isEmpty || name.localizedStandardContains(searchText) || keyPath.key.localizedStandardContains(searchText)
    }

    func items(matching searchText: String) -> [any FlagPoleItem] {
        guard isHidden == false else {
            return []
        }
        if let group = self as? FlagPoleItemGroup {
            return group.items.flatMap { $0.items(matching: searchText) }
        } else if matches(searchText: searchText) {
            return [self]
        } else {
            return []
        }
    }

}
