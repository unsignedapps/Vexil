import SwiftUI
import Vexil

public struct Vexillographer: View {

    @State private var searchText = ""

    public init() {}

    public var body: some View {
        FlagList(searchText: searchText)
            .searchable(text: $searchText)
    }

}

private struct FlagList: View {

    var searchText: String
    @Environment(\.flagPoleContext) private var flagPoleContext
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        List {
            if isSearching {
                let searchResult = flagPoleContext.items(matching: searchText)
                ForEach(searchResult, id: \.keyPath, content: \.content)
            } else {
                let visibleItems = flagPoleContext.items.filter { $0.isHidden == false }
                ForEach(visibleItems, id: \.keyPath, content: \.content)
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#endif
    }

}
