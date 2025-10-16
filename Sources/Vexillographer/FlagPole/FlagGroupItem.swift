import SwiftUI
import Vexil

struct FlagGroupItem<Value: FlagContainer>: FlagPoleItemGroup {

    var group: FlagGroupWigwag<Value>
    var items = [any FlagPoleItem]()

    init(_ group: FlagGroupWigwag<Value>) {
        self.group = group
    }

    var isHidden: Bool {
        group.displayOption == .hidden || visibleItems.isEmpty
    }

    var keyPath: FlagKeyPath {
        group.keyPath
    }

    var name: String {
        group.name
    }
    
    var visibleItems: [any FlagPoleItem] {
        items.filter { $0.isHidden == false }
    }

    func makeContent() -> any View {
        switch group.displayOption {
        case .navigation, nil:
            NavigationLink(group.name) {
                List {
                    if let description = group.description {
                        Section {
                            Text(description)
                        }
                    }
                    ForEach(visibleItems, id: \.keyPath, content: \.content)
                }
            }
        case .section:
            Section(group.name) {
                ForEach(visibleItems, id: \.keyPath, content: \.content)
            }
        case .hidden:
            EmptyView()
        }
    }

}
